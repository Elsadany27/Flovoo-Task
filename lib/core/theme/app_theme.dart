import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class ChatTheme extends ThemeExtension<ChatTheme> {
  const ChatTheme({
    required this.bubbleIncoming,
    required this.bubbleOutgoing,
  });

  final Color bubbleIncoming;
  final Color bubbleOutgoing;

  @override
  ChatTheme copyWith({
    Color? bubbleIncoming,
    Color? bubbleOutgoing,
  }) {
    return ChatTheme(
      bubbleIncoming: bubbleIncoming ?? this.bubbleIncoming,
      bubbleOutgoing: bubbleOutgoing ?? this.bubbleOutgoing,
    );
  }

  @override
  ChatTheme lerp(ThemeExtension<ChatTheme>? other, double t) {
    if (other is! ChatTheme) return this;
    return ChatTheme(
      bubbleIncoming:
          Color.lerp(bubbleIncoming, other.bubbleIncoming, t)!,
      bubbleOutgoing:
          Color.lerp(bubbleOutgoing, other.bubbleOutgoing, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        divider: AppColors.divider,
        primaryContainer: AppColors.primaryContainer,
        bubbleIncoming: AppColors.bubbleIncoming,
        bubbleOutgoing: AppColors.bubbleOutgoing,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        divider: AppColors.darkDivider,
        primaryContainer: AppColors.darkPrimaryContainer,
        bubbleIncoming: AppColors.darkBubbleIncoming,
        bubbleOutgoing: AppColors.bubbleOutgoing,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
    required Color primaryContainer,
    required Color bubbleIncoming,
    required Color bubbleOutgoing,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: const Color(0xFFDC2626),
      onError: Colors.white,
      surfaceContainerHighest: bubbleIncoming,
      onSurfaceVariant: textSecondary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: brightness == Brightness.dark
          ? Colors.white
          : AppColors.primaryDark,
      outline: divider,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      extensions: [
        ChatTheme(
          bubbleIncoming: bubbleIncoming,
          bubbleOutgoing: bubbleOutgoing,
        ),
      ],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

extension ChatThemeContext on BuildContext {
  ChatTheme get chatTheme => Theme.of(this).extension<ChatTheme>()!;
}
