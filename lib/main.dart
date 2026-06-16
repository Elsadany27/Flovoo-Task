import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/routes/app_routes.dart';
import 'core/services/session_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'features/chats/view/screens/chats_list_screen.dart';
import 'features/login/view/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const FlovooApp());
}

class FlovooApp extends StatelessWidget {
  const FlovooApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = getIt<ThemeService>();
    final savedEmail = getIt<SessionService>().currentEmail;

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flovoo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeService.themeMode,
          initialRoute: savedEmail != null ? AppRoutes.chats : AppRoutes.login,
          routes: {
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.chats: (_) {
              final email = getIt<SessionService>().currentEmail;
              if (email == null) {
                return const LoginScreen();
              }
              return ChatsListScreen(email: email);
            },
          },
        );
      },
    );
  }
}
