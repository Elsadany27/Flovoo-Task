class HiveConstants {
  HiveConstants._();

  static const String appBox = 'app_box';
  static const String chatsBox = 'chats_box_v2';

  static const String currentEmailKey = 'current_email';
  static const String themeModeKey = 'theme_mode';

  static String chatsKeyForEmail(String email) => 'chats_${email.toLowerCase()}';

  static const int messageTypeId = 0;
  static const int chatTypeId = 1;
}
