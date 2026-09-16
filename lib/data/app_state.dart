import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/chat_model.dart';
import '../models/notification_item.dart';
import '../models/rental_item.dart';
import '../models/rental_request.dart';
import '../models/review_item.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/listing_service.dart';
import '../services/borrow_request_service.dart';
import '../services/chat_service.dart';

class SaamaGoStore extends ChangeNotifier {
  final _userService = UserService();
  final _listingService = ListingService();
  final _borrowRequestService = BorrowRequestService();
  final _chatService = ChatService();
  final _transactionService = TransactionService();
  SaamaGoStore()
    : _items = [],
      _notifications = [],
      _transactions = [],
      _messages = [],
      _reviews = [] {
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load wallet balance
    final savedBalance = prefs.getInt('walletBalance');
    if (savedBalance != null) {
      _walletBalance = savedBalance;
    }

    // Load persisted items
    final itemsJson = prefs.getStringList('persistedItems');
    if (itemsJson != null) {
      final persistedItems = itemsJson
          .map((e) => RentalItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      _items.insertAll(0, persistedItems);
    }

    // Load persisted requests
    final requestsJson = prefs.getStringList('persistedRequests');
    if (requestsJson != null) {
      final persistedRequests = requestsJson
          .map((e) => RentalRequest.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      _requests.insertAll(0, persistedRequests);
    }

    notifyListeners();
  }

  Future<void> _savePersistedItems() async {
    final prefs = await SharedPreferences.getInstance();
    // Only save items that are not from mock data (check ID or just save all added items)
    // For simplicity, let's assume mock items have specific IDs like 'camera', 'drill'
    // But saving all items might be easier if not too large, or just new items
    final customItems = _items.where((i) => i.id.startsWith('item-')).toList();
    final jsonList = customItems.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('persistedItems', jsonList);
  }

  Future<void> _savePersistedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final customRequests = _requests.where((r) => r.id.startsWith('req-') && r.id.length > 5).toList(); 
    // mock requests are req-1, req-2. new requests use timestamp
    final jsonList = customRequests.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('persistedRequests', jsonList);
  }

  int _walletBalance = 0;
  int get walletBalance => _walletBalance;

  UserModel _profile = UserModel(
    uid: '',
    phoneNumber: '',
    displayName: 'User',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  UserModel get profile => _profile;

  Future<void> fetchUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        var p = await _userService.getUserProfile(currentUser.uid);
        if (p == null) {
          await _userService.createUserProfile(
            uid: currentUser.uid,
            phoneNumber: currentUser.phoneNumber ?? '',
          );
        } else {
          _profile = p;
          notifyListeners();
        }
      } catch (_) {
        // Retain local/cached profile during offline launch
      }

      _profileSubscription?.cancel();
      _profileSubscription = _userService.getUserProfileStream(currentUser.uid).listen(
        (userModel) {
          if (userModel != null) {
            _profile = userModel;
            notifyListeners();
          }
        },
        onError: (_) {
          // Gracefully retain current profile during connection drop
        },
      );

      _chatsSubscription?.cancel();
    _transactionsSubscription?.cancel();
      isChatsLoading = true;
      _chatsSubscription = _chatService.getUserChatsStream(currentUser.uid).listen(
        (firestoreChats) {
          _chats.clear();
          _chats.addAll(firestoreChats);
          isChatsLoading = false;
          chatsError = null;
          notifyListeners();
        },
        onError: (error) {
          isChatsLoading = false;
          chatsError = _parseError(error);
          notifyListeners();
        },
      );

      await fetchTransactions();
      await fetchListings();
      await fetchRequests();
    }
  }

  
  Future<void> fetchTransactions() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _transactionsSubscription?.cancel();
    isTransactionsLoading = true;
    transactionsError = null;
    notifyListeners();

    _transactionsSubscription = _transactionService.getUserTransactionsStream(currentUser.uid).listen(
      (firestoreTransactions) {
        _transactions.clear();
        _transactions.addAll(firestoreTransactions);
        
        // Compute wallet balance
        int newBalance = 0;
        for (var t in firestoreTransactions) {
          if (t.status == TransactionStatus.completed) {
             if (t.isPositive) {
               newBalance += t.amount;
             } else {
               newBalance -= t.amount;
             }
          }
        }
        _walletBalance = newBalance;
        
        isTransactionsLoading = false;
        transactionsError = null;
        notifyListeners();
      },
      onError: (error) {
        isTransactionsLoading = false;
        transactionsError = _parseError(error);
        notifyListeners();
      },
    );
  }

  Future<void> fetchRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _requestsSubscription?.cancel();
    isRequestsLoading = true;
    requestsError = null;
    notifyListeners();

    _requestsSubscription = _borrowRequestService.getRequestsForUserStream(currentUser.uid).listen(
      (firestoreRequests) {
        _requests.clear();
        _requests.addAll(firestoreRequests);
        isRequestsLoading = false;
        requestsError = null;
        notifyListeners();
      },
      onError: (error) {
        isRequestsLoading = false;
        requestsError = _parseError(error);
        notifyListeners();
      },
    );
  }

  Future<void> updateRequestStatus(String id, RequestStatus status) async {
    final index = _requests.indexWhere((req) => req.id == id);
    if (index == -1) return;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final previousStatus = _requests[index].status;
    _requests[index] = _requests[index].copyWith(status: status);
    notifyListeners();

    if (currentUid != null) {
      try {
        await _borrowRequestService.updateRequestStatus(id, status);
      } catch (e) {
        // Rollback optimistic update on network failure
        _requests[index] = _requests[index].copyWith(status: previousStatus);
        notifyListeners();
        throw Exception(_parseError(e));
      }
    } else {
      _savePersistedRequests();
    }
  }

  String _parseError(Object error) {
    final str = error.toString().toLowerCase();
    if (str.contains('unavailable') || str.contains('network') || str.contains('offline')) {
      return 'Network connection lost. Please check your internet connection.';
    }
    if (str.contains('permission-denied')) {
      return 'You do not have permission to access this data.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> fetchListings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }
    
    _listingsSubscription?.cancel();
    isListingsLoading = true;
    listingsError = null;
    notifyListeners();

    _listingsSubscription = _listingService.getListingsStream().listen(
      (firestoreListings) {
        _items.clear();
        _items.addAll(firestoreListings);
        isListingsLoading = false;
        listingsError = null;
        notifyListeners();
      },
      onError: (error) {
        isListingsLoading = false;
        listingsError = _parseError(error);
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _requestsSubscription?.cancel();
    _profileSubscription?.cancel();
    _chatsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await _userService.updateUserProfile(currentUser.uid, data);
      } catch (e) {
        throw Exception(_parseError(e));
      }
    } else {
      // Developer Login Mock behavior:
      _profile = _profile.copyWith(
        displayName: data['displayName'] as String?,
        location: data['location'] as String?,
        profileImageUrl: data['profileImageUrl'] as String?,
      );
      notifyListeners();
    }
  }
  StreamSubscription<UserModel?>? _profileSubscription;
  final List<RentalItem> _items;
  StreamSubscription<List<RentalItem>>? _listingsSubscription;
  bool isListingsLoading = false;
  String? listingsError;

  final List<RentalRequest> _requests = [];
  StreamSubscription<List<RentalRequest>>? _requestsSubscription;
  bool isRequestsLoading = false;
  String? requestsError;
  final List<NotificationItem> _notifications;
  final List<TransactionModel> _transactions;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  bool isTransactionsLoading = false;
  String? transactionsError;
  final List<ChatModel> _chats = [];
  StreamSubscription<List<ChatModel>>? _chatsSubscription;
  bool isChatsLoading = false;
  String? chatsError;
  List<ChatModel> get chats => List.unmodifiable(_chats);

  final List<ChatMessage> _messages;
  final List<ReviewItem> _reviews;

  String searchQuery = '';
  String selectedCategory = 'All';
  bool showGrid = true;
  double maxPrice = 10000;
  double maxDistance = 10;
  double minRating = 0;
  String condition = 'Any';
  String sortOption = 'Nearest';
  bool availableOnly = false;

  List<String> get categories => const [
    'All',
    'Electronics',
    'Books',
    'Sports',
    'Tools',
    'Events',
    'Furniture',
    'Gaming',
    'Music',
  ];
  List<RentalItem> get items => List.unmodifiable(_items);
  List<RentalRequest> get requests => List.unmodifiable(_requests);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ReviewItem> get reviews => List.unmodifiable(_reviews);
  int get unreadNotifications =>
      _notifications.where((item) => !item.isRead).length;

  RentalItem get firstItem => _items.first;

  List<RentalItem> get filteredItems {
    final query = searchQuery.trim().toLowerCase();
    final filtered = _items.where((item) {
      final categoryMatches =
          selectedCategory == 'All' || item.category == selectedCategory;
      final queryMatches =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      final priceMatches = item.pricePerDay <= maxPrice;
      final distanceMatches = item.distanceKm <= maxDistance;
      final ratingMatches = item.rating >= minRating;
      final conditionMatches =
          condition == 'Any' || item.condition == condition;
      final availabilityMatches =
          !availableOnly || item.availability == 'Today';
      return categoryMatches &&
          queryMatches &&
          priceMatches &&
          distanceMatches &&
          ratingMatches &&
          conditionMatches &&
          availabilityMatches;
    }).toList();

    switch (sortOption) {
      case 'Price low to high':
        filtered.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'Price high to low':
        filtered.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'Highest rated':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest':
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      default:
        filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }

    return filtered;
  }

  List<RentalRequest> requestsByStatus(RequestStatus? status) {
    if (status == null) {
      return requests;
    }
    return _requests.where((request) => request.status == status).toList();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void toggleGrid() {
    showGrid = !showGrid;
    notifyListeners();
  }

  void applyFilters({
    required String category,
    required double price,
    required double distance,
    required String selectedCondition,
    required double rating,
    required String sort,
    required bool available,
  }) {
    selectedCategory = category;
    maxPrice = price;
    maxDistance = distance;
    condition = selectedCondition;
    minRating = rating;
    sortOption = sort;
    availableOnly = available;
    notifyListeners();
  }

  void resetFilters() {
    selectedCategory = 'All';
    maxPrice = 10000;
    maxDistance = 10;
    minRating = 0;
    condition = 'Any';
    sortOption = 'Nearest';
    availableOnly = false;
    notifyListeners();
  }

  void toggleFavourite(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) {
      return;
    }
    final item = _items[index];
    _items[index] = item.copyWith(isFavourite: !item.isFavourite);
    notifyListeners();
  }

  Future<void> addBorrowRequest(RentalItem item, int durationDays, int amount, {String? message}) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null) {
      if (currentUid == item.ownerId) {
        throw Exception('You cannot request your own item.');
      }
      final activeDuplicate = _requests.any((req) =>
          req.listingId == item.id &&
          req.borrowerId == currentUid &&
          (req.status == RequestStatus.pending || req.status == RequestStatus.accepted));
      if (activeDuplicate) {
        throw Exception('You already have an active request for this item.');
      }
    }

    final newRequest = RentalRequest(
      id: 'req-',
      item: item,
      durationDays: durationDays,
      amount: amount,
      personName: item.ownerName,
      status: RequestStatus.pending,
      dateLabel: 'Today',
      listingId: item.id,
      listingTitle: item.name,
      borrowerId: currentUid ?? '',
      borrowerName: profile.name,
      ownerId: item.ownerId,
      ownerName: item.ownerName,
      message: message,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    RentalRequest addedRequest = newRequest;
    if (currentUid != null) {
      try {
        addedRequest = await _borrowRequestService.createRequest(newRequest);
      } catch (e) {
        throw Exception(_parseError(e));
      }
    }

    if (currentUid == null) {
      _requests.insert(0, addedRequest);
      _savePersistedRequests();
      notifyListeners();
    }
  }

  Future<void> publishItem({
    required String name,
    required String category,
    required String description,
    required int price,
    required int deposit,
    required String condition,
    required String availability,
    required bool delivery,
    String? imagePath,
  }) async {
    final newItem = RentalItem(
      id: 'item-',
      name: name,
      category: category,
      pricePerDay: price,
      distanceKm: 0.6,
      rating: 5,
      deposit: deposit,
      condition: condition,
      availability: availability,
      description: description,
      ownerName: profile.name,
      ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerTrustScore: profile.trustScore,
      icon: delivery
          ? Icons.local_shipping_rounded
          : Icons.inventory_2_rounded,
      gradient: const [Color(0xFFA78BFA), Color(0xFF312E81)],
      imagePath: imagePath,
    );

    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await _listingService.createListing(newItem);
      } catch (e) {
        throw Exception(_parseError(e));
      }
    } else {
      _items.insert(0, newItem);
      _savePersistedItems();
      notifyListeners();
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) {
      return;
    }
    _messages.add(ChatMessage(text: text.trim(), time: 'Now', isMine: true));
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void submitReview(String text, double rating) {
    _reviews.insert(
      0,
      ReviewItem(
        reviewerName: profile.name,
        date: 'Just now',
        rating: rating,
        text: text,
      ),
    );
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<SaamaGoStore> {
  const AppStateScope({
    required SaamaGoStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static SaamaGoStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope missing from widget tree');
    return scope!.notifier!;
  }
}
