// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:flovoo_task/data/services/chat_storage_service.dart';
// import 'package:flovoo_task/data/services/session_service.dart';
// import 'package:flovoo_task/features/login/view/screens/login_screen.dart';
//
// void main() {
//   testWidgets('Login screen shows email field', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MultiRepositoryProvider(
//         providers: [
//           RepositoryProvider(create: (_) => SessionService()),
//           RepositoryProvider(create: (_) => ChatStorageService()),
//         ],
//         child: const MaterialApp(home: LoginScreen()),
//       ),
//     );
//
//     expect(find.text('Flovoo'), findsOneWidget);
//     expect(find.byType(TextFormField), findsOneWidget);
//     expect(find.text('Continue'), findsOneWidget);
//   });
// }
