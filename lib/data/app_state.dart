import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/notification_item.dart';
import '../models/rental_item.dart';
import '../models/rental_request.dart';
import '../models/review_item.dart';
import '../models/transaction_item.dart';
import '../models/user_profile.dart';
import 'mock_data.dart';

class SaamaGoStore extends ChangeNotifier {
  SaamaGoStore()
    : _items = List<RentalItem>.from(MockData.items),
      _notifications = List<NotificationItem>.from(MockData.notifications),
      _transactions = List<TransactionItem>.from(MockData.transactions),
      _messages = List<ChatMessage>.from(MockData.messages),
      _reviews = List<ReviewItem>.from(MockData.reviews) {
    _requests = MockData.requests(_items);
  }

  final UserProfile profile = MockData.profile;
  final List<RentalItem> _items;
  late final List<RentalRequest> _requests;
  final List<NotificationItem> _notifications;
  final List<TransactionItem> _transactions;
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

  List<String> get categories => MockData.categories;
  List<RentalItem> get items => List.unmodifiable(_items);
  List<RentalRequest> get requests => List.unmodifiable(_requests);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);
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

  void addBorrowRequest(RentalItem item, int durationDays, int amount) {
    _requests.insert(
      0,
      RentalRequest(
        id: 'req-${DateTime.now().millisecondsSinceEpoch}',
        item: item,
        durationDays: durationDays,
        amount: amount,
        personName: item.ownerName,
        status: RequestStatus.pending,
        dateLabel: 'Today',
      ),
    );
    notifyListeners();
  }

  void publishItem({
    required String name,
    required String category,
    required String description,
    required int price,
    required int deposit,
    required String condition,
    required String availability,
    required bool delivery,
  }) {
    _items.insert(
      0,
      RentalItem(
        id: 'item-${DateTime.now().millisecondsSinceEpoch}',
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
        ownerTrustScore: profile.trustScore,
        icon: delivery
            ? Icons.local_shipping_rounded
            : Icons.inventory_2_rounded,
        gradient: const [Color(0xFFA78BFA), Color(0xFF312E81)],
      ),
    );
    notifyListeners();
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
