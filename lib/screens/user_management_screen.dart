import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import 'package:go_router/go_router.dart';

// Provider para cargar usuarios
final usersNotifierProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier();
});

// Estado de los usuarios
class UsersState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier para manejar el estado de usuarios
class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier() : super(UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await http.get(
        Uri.parse('https://giit-api-rest.onrender.com/usuarios/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<User> users = jsonData.map((json) => User.fromJson(json)).toList();
        
        state = state.copyWith(users: users, isLoading: false);
      } else {
        state = state.copyWith(
          error: 'Error del servidor: ${response.statusCode}',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error de conexión: $e',
        isLoading: false,
      );
    }
  }
}

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersNotifierProvider);
    final usersNotifier = ref.read(usersNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => usersNotifier.loadUsers(),
          ),
        ],
      ),
      body: _buildContent(usersState, usersNotifier),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/create-user');
          // Refrescar la lista cuando se regrese
          ref.read(usersNotifierProvider.notifier).loadUsers();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(UsersState state, UsersNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando usuarios...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => notifier.loadUsers(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay usuarios registrados'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.nombre} ${user.apellido}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await context.push('/edit-user', extra: user);
                          // Refrescar la lista cuando se regrese
                          notifier.loadUsers();
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, user, notifier);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text('Tel: ${user.telefono}'),
                      backgroundColor: Colors.grey[200],
                    ),
                    Chip(
                      label: Text(user.institucion),
                      backgroundColor: Colors.blue[100],
                    ),
                    Chip(
                      label: Text(user.especialidad),
                      backgroundColor: Colors.green[100],
                    ),
                    if (user.rol != null)
                      Chip(
                        label: Text(user.rol!.nombreRol),
                        backgroundColor: Colors.orange[100],
                      ),
                    Chip(
                      label: Text(user.estado),
                      backgroundColor: user.estado == 'activo' ? Colors.green[100] : Colors.red[100],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, User user, UsersNotifier notifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: Text('¿Estás seguro de que deseas eliminar a ${user.nombre} ${user.apellido}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteUser(context, user, notifier);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(BuildContext context, User user, UsersNotifier notifier) async {
    try {
      final response = await http.delete(
        Uri.parse('https://giit-api-rest.onrender.com/usuarios/${user.idUsuario}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refrescar la lista primero
        notifier.loadUsers();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuario ${user.nombre} ${user.apellido} eliminado exitosamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar usuario: ${response.statusCode}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Delete error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 