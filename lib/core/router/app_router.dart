import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/addresses/addresses_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/catalog/product_list_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/coupons/coupons_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/order_success_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/reviews/write_review_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/seller/become_seller_screen.dart';
import '../../features/settings/about_screen.dart';
import '../../features/settings/help_center_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/store/store_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const MainShell()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) =>
          ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(showBack: true),
    ),
    GoRoute(
      path: '/coupons',
      builder: (context, state) => const CouponsScreen(),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order/:id',
      builder: (context, state) =>
          OrderDetailScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/order-success/:id',
      builder: (context, state) =>
          OrderSuccessScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(showBack: true),
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) => WriteReviewScreen(
        productId: state.uri.queryParameters['product'] ?? '',
        orderId: state.uri.queryParameters['order'] ?? '',
      ),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) => ProductListScreen(
        categoryId: state.pathParameters['id'],
        title: state.uri.queryParameters['name'] ?? 'الفئة',
        query: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => ProductListScreen(
        title: state.uri.queryParameters['title'] ?? 'كل المنتجات',
      ),
    ),
    GoRoute(
      path: '/store/:vendorId',
      builder: (context, state) =>
          StoreScreen(vendorId: state.pathParameters['vendorId']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/become-seller',
      builder: (context, state) => const BecomeSellerScreen(),
    ),
  ],
);
