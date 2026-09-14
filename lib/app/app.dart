import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../data/app_state.dart';
import '../models/rental_item.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/otp_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/explore/filter_screen.dart';
import '../screens/explore/map_view_screen.dart';
import '../screens/items/item_details_screen.dart';
import '../screens/items/list_item_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/permissions/location_permission_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/refer_and_earn_screen.dart';
import '../screens/profile/reviews_screen.dart';
import '../screens/requests/borrow_confirmation_screen.dart';
import '../screens/requests/requests_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/support/help_support_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import 'routes.dart';

class SaamaGoApp extends StatefulWidget {
  const SaamaGoApp({super.key});

  @override
  State<SaamaGoApp> createState() => _SaamaGoAppState();
}

class _SaamaGoAppState extends State<SaamaGoApp> {
  late final SaamaGoStore _store;

  @override
  void initState() {
    super.initState();
    _store = SaamaGoStore();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      store: _store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.dark(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case AppRoutes.splash:
        page = const SplashScreen();
        break;
      case AppRoutes.onboarding:
        page = const OnboardingScreen();
        break;
      case AppRoutes.login:
        page = const LoginScreen();
        break;
      case AppRoutes.otp:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = OtpScreen(
          mobile: args['mobile'] as String? ?? '9876543210',
          verificationId: args['verificationId'] as String? ?? '',
        );
        break;
      case AppRoutes.location:
        page = const LocationPermissionScreen();
        break;
      case AppRoutes.shell:
        page = MainShell(initialIndex: settings.arguments as int? ?? 0);
        break;
      case AppRoutes.itemDetails:
        page = ItemDetailsScreen(
          item: settings.arguments as RentalItem? ?? _store.firstItem,
        );
        break;
      case AppRoutes.borrowConfirmation:
        page = BorrowConfirmationScreen(
          item: settings.arguments as RentalItem? ?? _store.firstItem,
        );
        break;
      case AppRoutes.requests:
        page = const RequestsScreen(showAppBar: true);
        break;
      case AppRoutes.chat:
        page = ChatScreen(item: settings.arguments as RentalItem?);
        break;
      case AppRoutes.wallet:
        page = const WalletScreen(showAppBar: true);
        break;
      case AppRoutes.listItem:
        page = const ListItemScreen(showAppBar: true);
        break;
      case AppRoutes.notifications:
        page = const NotificationsScreen();
        break;
      case AppRoutes.profile:
        page = const ProfileScreen(showAppBar: true);
        break;
      case AppRoutes.settings:
        page = const SettingsScreen();
        break;
      case AppRoutes.filters:
        page = const FilterScreen();
        break;
      case AppRoutes.mapView:
        page = const MapViewScreen();
        break;
      case AppRoutes.reviews:
        page = const ReviewsScreen();
        break;
      case AppRoutes.refer:
        page = const ReferAndEarnScreen();
        break;
      case AppRoutes.help:
        page = const HelpSupportScreen();
        break;
      default:
        page = const MainShell();
    }

    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 220),
    );
  }
}
