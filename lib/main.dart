import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/create_user_screen.dart';
import 'screens/edit_user_screen.dart';
import 'models/user.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/create-user',
          builder: (context, state) => const CreateUserScreen(),
        ),
        GoRoute(
          path: '/edit-user',
          builder: (context, state) {
            final user = state.extra as User;
            return EditUserScreen(user: user);
          },
        ),
        // Aquí se agregará el panel de administración luego
      ],
    );
    return MaterialApp.router(
      title: 'GIIT',
      routerConfig: _router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
