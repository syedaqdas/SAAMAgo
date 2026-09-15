import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/chat_message.dart';
import '../models/notification_item.dart';
import '../models/rental_item.dart';
import '../models/rental_request.dart';
import '../models/review_item.dart';
import '../models/transaction_item.dart';


abstract final class MockData {
  static const categories = [
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

  

  static final items = <RentalItem>[
    RentalItem(
      id: 'camera',
      name: 'Canon DSLR Camera',
      category: 'Electronics',
      pricePerDay: 400,
      distanceKm: 1.4,
      rating: 4.8,
      deposit: 2000,
      condition: 'Excellent',
      availability: 'Today',
      description:
          'Well maintained DSLR camera with 18-55mm lens. Perfect for photography and videography projects.',
      ownerName: 'Aqdas Imam',
      ownerTrustScore: 98,
      icon: Icons.photo_camera_rounded,
      gradient: [const Color(0xFF4C5D78), const Color(0xFF0E121E)],
      isFavourite: true,
    ),
    RentalItem(
      id: 'drill',
      name: 'Bosch Drill Machine',
      category: 'Tools',
      pricePerDay: 180,
      distanceKm: 2.2,
      rating: 4.7,
      deposit: 900,
      condition: 'Good',
      availability: 'Tomorrow',
      description:
          'Cordless drill machine with bits and carry case. Great for quick home fixes and DIY work.',
      ownerName: 'Rahul Sharma',
      ownerTrustScore: 94,
      icon: Icons.construction_rounded,
      gradient: [const Color(0xFFF59E0B), const Color(0xFF422006)],
    ),
    RentalItem(
      id: 'guitar',
      name: 'Acoustic Guitar',
      category: 'Music',
      pricePerDay: 220,
      distanceKm: 1.3,
      rating: 4.5,
      deposit: 1200,
      condition: 'Good',
      availability: 'Today',
      description:
          'Warm sounding acoustic guitar, freshly tuned and ready for events, practice sessions, or recordings.',
      ownerName: 'Priya Singh',
      ownerTrustScore: 91,
      icon: Icons.music_note_rounded,
      gradient: [const Color(0xFFA855F7), const Color(0xFF312E81)],
    ),
    RentalItem(
      id: 'tent',
      name: 'Camping Tent',
      category: 'Sports',
      pricePerDay: 300,
      distanceKm: 2.6,
      rating: 4.6,
      deposit: 1500,
      condition: 'Excellent',
      availability: 'Weekend',
      description:
          'Two-person waterproof tent with poles, stakes, and compact carry bag for quick outdoor trips.',
      ownerName: 'Neha Khan',
      ownerTrustScore: 89,
      icon: Icons.terrain_rounded,
      gradient: [const Color(0xFF22C55E), const Color(0xFF14532D)],
    ),
    RentalItem(
      id: 'macbook',
      name: 'MacBook Air',
      category: 'Electronics',
      pricePerDay: 650,
      distanceKm: 4.0,
      rating: 4.9,
      deposit: 5000,
      condition: 'Excellent',
      availability: 'Today',
      description:
          'Lightweight laptop with charger. Ideal for presentations, travel work, and short-term projects.',
      ownerName: 'Arjun Patel',
      ownerTrustScore: 99,
      icon: Icons.laptop_mac_rounded,
      gradient: [const Color(0xFF94A3B8), const Color(0xFF1E293B)],
    ),
    RentalItem(
      id: 'speaker',
      name: 'Bluetooth Speaker',
      category: 'Events',
      pricePerDay: 200,
      distanceKm: 1.8,
      rating: 4.4,
      deposit: 1000,
      condition: 'Good',
      availability: 'Today',
      description:
          'Portable speaker with deep bass and long battery life for small gatherings and house parties.',
      ownerName: 'Meera Rao',
      ownerTrustScore: 87,
      icon: Icons.speaker_rounded,
      gradient: [const Color(0xFF38BDF8), const Color(0xFF164E63)],
    ),
    RentalItem(
      id: 'projector',
      name: 'Projector',
      category: 'Events',
      pricePerDay: 500,
      distanceKm: 3.1,
      rating: 4.6,
      deposit: 2500,
      condition: 'Excellent',
      availability: 'Tomorrow',
      description:
          'HD projector with HDMI cable and remote. Works well for movie nights and small presentations.',
      ownerName: 'Kabir Ali',
      ownerTrustScore: 93,
      icon: Icons.connected_tv_rounded,
      gradient: [const Color(0xFF818CF8), const Color(0xFF1E1B4B)],
    ),
    RentalItem(
      id: 'bicycle',
      name: 'Bicycle',
      category: 'Sports',
      pricePerDay: 150,
      distanceKm: 0.8,
      rating: 4.3,
      deposit: 800,
      condition: 'Good',
      availability: 'Today',
      description:
          'Hybrid city bicycle with lock and helmet. Comfortable for errands and casual rides.',
      ownerName: 'Sana Mir',
      ownerTrustScore: 86,
      icon: Icons.directions_bike_rounded,
      gradient: [const Color(0xFFFB7185), const Color(0xFF4C0519)],
    ),
    RentalItem(
      id: 'console',
      name: 'Gaming Console',
      category: 'Gaming',
      pricePerDay: 450,
      distanceKm: 2.9,
      rating: 4.8,
      deposit: 3000,
      condition: 'Excellent',
      availability: 'Weekend',
      description:
          'Console with two controllers and popular party games for weekend fun with friends.',
      ownerName: 'Dev Malhotra',
      ownerTrustScore: 95,
      icon: Icons.sports_esports_rounded,
      gradient: [const Color(0xFF8B5CF6), const Color(0xFF2E1065)],
    ),
    RentalItem(
      id: 'books',
      name: 'Study Books',
      category: 'Books',
      pricePerDay: 60,
      distanceKm: 1.1,
      rating: 4.5,
      deposit: 300,
      condition: 'Like New',
      availability: 'Today',
      description:
          'Curated study books and business titles, including Rich Dad Poor Dad and exam prep guides.',
      ownerName: 'Farhan Qureshi',
      ownerTrustScore: 90,
      icon: Icons.menu_book_rounded,
      gradient: [const Color(0xFFF97316), const Color(0xFF431407)],
    ),
  ];

  static List<RentalRequest> requests(List<RentalItem> items) => [
    RentalRequest(
      id: 'req-1',
      item: items[0],
      durationDays: 3,
      amount: 3200,
      personName: 'Aqdas Imam',
      status: RequestStatus.pending,
      dateLabel: '31 Oct',
    ),
    RentalRequest(
      id: 'req-2',
      item: items[5],
      durationDays: 2,
      amount: 900,
      personName: 'Meera Rao',
      status: RequestStatus.accepted,
      dateLabel: '2 Dec',
    ),
    RentalRequest(
      id: 'req-3',
      item: items[4],
      durationDays: 5,
      amount: 6250,
      personName: 'Arjun Patel',
      status: RequestStatus.completed,
      dateLabel: '19 Dec',
    ),
    RentalRequest(
      id: 'req-4',
      item: items[3],
      durationDays: 2,
      amount: 1700,
      personName: 'Neha Khan',
      status: RequestStatus.cancelled,
      dateLabel: '1 Oct',
    ),
  ];

  static final notifications = <NotificationItem>[
    NotificationItem(
      id: 'n1',
      title: 'Request accepted',
      body: 'Your request for Canon DSLR has been accepted.',
      time: '10:30 AM',
      icon: Icons.verified_rounded,
      color: AppColors.success,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Payment successful',
      body: 'Payment of ₹3,200 was successful.',
      time: '10:36 AM',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.success,
      isRead: true,
    ),
    NotificationItem(
      id: 'n3',
      title: 'Return reminder',
      body: 'Return Canon DSLR tomorrow, 10:00 AM.',
      time: 'Yesterday',
      icon: Icons.access_time_filled_rounded,
      color: AppColors.warning,
    ),
    NotificationItem(
      id: 'n4',
      title: 'New item nearby',
      body: 'A Bose Speaker is available 1.8 km away.',
      time: 'Yesterday',
      icon: Icons.place_rounded,
      color: AppColors.lightPurple,
      isRead: true,
    ),
    NotificationItem(
      id: 'n5',
      title: 'New chat message',
      body: 'Aqdas Imam sent pickup details.',
      time: 'Yesterday',
      icon: Icons.chat_bubble_rounded,
      color: AppColors.error,
    ),
    NotificationItem(
      id: 'n6',
      title: 'Referral reward',
      body: 'You earned 50 SAAMA Coins.',
      time: '2 days ago',
      icon: Icons.card_giftcard_rounded,
      color: AppColors.primaryPurple,
      isRead: true,
    ),
  ];

  static final transactions = <TransactionItem>[
    TransactionItem(
      title: 'Added Money',
      subtitle: 'Today, 2:25 PM',
      amount: 1000,
      isPositive: true,
      icon: Icons.add_card_rounded,
    ),
    TransactionItem(
      title: 'Refund Received',
      subtitle: '18 May 2025',
      amount: 900,
      isPositive: true,
      icon: Icons.refresh_rounded,
    ),
    TransactionItem(
      title: 'Payment for DSLR',
      subtitle: '14 May 2025',
      amount: 2300,
      isPositive: false,
      icon: Icons.photo_camera_rounded,
    ),
    TransactionItem(
      title: 'Security Deposit Held',
      subtitle: '13 May 2025',
      amount: 2000,
      isPositive: false,
      icon: Icons.lock_rounded,
    ),
  ];

  static final messages = <ChatMessage>[
    ChatMessage(
      text: 'Hi, is the camera still available?',
      time: '10:31 AM',
      isMine: false,
    ),
    ChatMessage(text: 'Yes, it is available.', time: '10:33 AM', isMine: true),
    ChatMessage(
      text: 'Great! Can I pick it up tomorrow?',
      time: '10:34 AM',
      isMine: false,
    ),
    ChatMessage(
      text: 'Sure, you can pick it up tomorrow after 11 AM.',
      time: '10:35 AM',
      isMine: true,
    ),
    ChatMessage(text: 'Thank you.', time: '10:36 AM', isMine: true),
  ];

  static final reviews = <ReviewItem>[
    ReviewItem(
      reviewerName: 'Rohit Sharma',
      date: '2 days ago',
      rating: 5,
      text: 'Great camera. Everything was perfect and the handover was quick.',
    ),
    ReviewItem(
      reviewerName: 'Priya Singh',
      date: '1 week ago',
      rating: 4.8,
      text: 'Very good experience. Item was clean and exactly as described.',
    ),
    ReviewItem(
      reviewerName: 'Arjun Patel',
      date: '2 weeks ago',
      rating: 4.9,
      text: 'Item was in excellent condition. Highly recommended.',
    ),
  ];
}
