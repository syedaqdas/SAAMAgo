import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import 'transaction_service.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final TransactionService _transactionService = TransactionService();
  
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator, or real IP for physical devices.
  static const String _backendBaseUrl = 'http://10.0.2.2:3000';
  
  // The key id is fetched from backend or hardcoded here depending on architecture.
  // We'll receive it from /createOrder response to keep it safe.
  // We'll receive it from /createOrder response to keep it safe.
  String? _currentPendingTransactionId;

  Function(String)? onPaymentSuccess;
  Function(String)? onPaymentError;

  PaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      if (_currentPendingTransactionId == null) {
        throw Exception('Transaction ID is missing');
      }

      await _verifyPaymentOnBackend(
        _currentPendingTransactionId!,
        response.paymentId,
        response.orderId,
        response.signature,
      );
      
      if (onPaymentSuccess != null) {
        onPaymentSuccess!('Payment verified successfully!');
      }
    } catch (e) {
      if (onPaymentError != null) {
        onPaymentError!('Payment verification failed: $e');
      }
    } finally {
      _currentPendingTransactionId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onPaymentError != null) {
      onPaymentError!(response.message ?? 'Payment failed or cancelled.');
    }
    _currentPendingTransactionId = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onPaymentError != null) {
      onPaymentError!('External wallets are not supported yet.');
    }
  }

  Future<void> initiateCheckout({
    required int amountInPaise,
    required String orderId,
    required String description,
    required String pendingTransactionId,
    required String keyId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String contact = currentUser?.phoneNumber ?? '';
    final String email = currentUser?.email ?? '';
    
    _currentPendingTransactionId = pendingTransactionId;

    var options = {
      'key': keyId,
      'amount': amountInPaise,
      'name': 'SAAMAgo',
      'order_id': orderId,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {
        'color': '#059669', // Brand color matching AppColors.primaryTeal
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (onPaymentError != null) {
        onPaymentError!(e.toString());
      }
    }
  }

  Future<Map<String, dynamic>> _createOrderOnBackend(String transactionId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final idToken = await currentUser.getIdToken();
    
    final response = await http.post(
      Uri.parse('$_backendBaseUrl/payments/createOrder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'transactionId': transactionId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<void> _verifyPaymentOnBackend(
    String transactionId,
    String? paymentId,
    String? orderId,
    String? signature,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final idToken = await currentUser.getIdToken();

    final response = await http.post(
      Uri.parse('$_backendBaseUrl/payments/verifyPayment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'transactionId': transactionId,
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Payment verification failed: ${response.body}');
    }
  }

  Future<void> processPayment({
    required int amountInINR,
    required String description,
    required TransactionType type,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        if (onPaymentSuccess != null) {
          onPaymentSuccess!('Mock payment successful for Developer Login');
        }
      } else {
        if (onPaymentError != null) {
          onPaymentError!('Authentication required to process payments.');
        }
      }
      return;
    }

    try {
      final pendingTx = TransactionModel(
        id: '',
        userId: currentUser.uid,
        amount: amountInINR,
        type: type,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
        description: description,
      );
      
      final createdTx = await _transactionService.createTransaction(pendingTx);

      final orderData = await _createOrderOnBackend(createdTx.id);

      await initiateCheckout(
        amountInPaise: amountInINR * 100,
        orderId: orderData['orderId'],
        description: description,
        pendingTransactionId: createdTx.id,
        keyId: orderData['keyId'],
      );

    } catch (e) {
      if (onPaymentError != null) {
        onPaymentError!('Failed to initialize payment: $e');
      }
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
