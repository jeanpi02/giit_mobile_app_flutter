import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final loginFormProvider = StateProvider.autoDispose<_LoginFormState>((ref) => _LoginFormState());

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormProvider);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Iniciar Sesión', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blue)),
              const SizedBox(height: 32),
              TextField(
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => ref.read(loginFormProvider.notifier).update((state) => state.copyWith(email: value)),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                obscureText: true,
                onChanged: (value) => ref.read(loginFormProvider.notifier).update((state) => state.copyWith(password: value)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: formState.loading
                      ? null
                      : () async {
                          ref.read(loginFormProvider.notifier).update((state) => state.copyWith(loading: true));
                          final success = await _login(ref, context);
                          ref.read(loginFormProvider.notifier).update((state) => state.copyWith(loading: false));
                          if (success) {
                            if (context.mounted) context.push('/admin');
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales incorrectas')));
                            }
                          }
                        },
                  child: formState.loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Ingresar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginFormState {
  final String email;
  final String password;
  final bool loading;
  _LoginFormState({this.email = '', this.password = '', this.loading = false});
  _LoginFormState copyWith({String? email, String? password, bool? loading}) => _LoginFormState(
        email: email ?? this.email,
        password: password ?? this.password,
        loading: loading ?? this.loading,
      );
}

Future<bool> _login(WidgetRef ref, BuildContext context) async {
  final form = ref.read(loginFormProvider);
  try {
    final response = await http.post(
      Uri.parse('https://giit-api-rest.onrender.com/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': form.email, 'password': form.password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Aquí puedes guardar el usuario en un provider global si lo deseas
        return true;
      }
    }
    return false;
  } catch (_) {
    return false;
  }
} 