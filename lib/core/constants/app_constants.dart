class AppConstants {
  // API
  static const String baseUrl = 'http://192.168.1.55:5000/api';
  
  // Endpoints - Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String uploadAvatar = '/auth/upload-avatar';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String technicians = '/auth/technicians';
  
  // Endpoints - Services
  static const String services = '/services';
  static const String myServices = '/services/my-services';
  
  // Endpoints - Bookings
  static const String bookings = '/bookings';
  
  // Endpoints - Reviews
  static const String reviews = '/reviews';
  
  // Endpoints - Messages
  static const String messages = '/messages';
  
  // Endpoints - Notifications
  static const String notifications = '/notifications';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // App Info
  static const String appName = 'BeautyConnect';
  static const String appTagline = 'YOUR PERSONAL WELLNESS RITUAL';
  static const String appSubTagline = 'Crafting Excellence';
}