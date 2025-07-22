import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Estado del formulario de creación de usuario
class CreateUserFormState {
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String institucion;
  final String especialidad;
  final String password;
  final int idRol;
  final String estado;
  final bool isLoading;
  final String? error;

  CreateUserFormState({
    this.nombre = '',
    this.apellido = '',
    this.email = '',
    this.telefono = '',
    this.institucion = '',
    this.especialidad = '',
    this.password = '',
    this.idRol = 2, // Por defecto investigador
    this.estado = 'activo',
    this.isLoading = false,
    this.error,
  });

  CreateUserFormState copyWith({
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? institucion,
    String? especialidad,
    String? password,
    int? idRol,
    String? estado,
    bool? isLoading,
    String? error,
  }) {
    return CreateUserFormState(
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      institucion: institucion ?? this.institucion,
      especialidad: especialidad ?? this.especialidad,
      password: password ?? this.password,
      idRol: idRol ?? this.idRol,
      estado: estado ?? this.estado,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider para el formulario de creación
final createUserFormProvider = StateNotifierProvider<CreateUserFormNotifier, CreateUserFormState>((ref) {
  return CreateUserFormNotifier();
});

class CreateUserFormNotifier extends StateNotifier<CreateUserFormState> {
  CreateUserFormNotifier() : super(CreateUserFormState());

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'nombre':
        state = state.copyWith(nombre: value);
        break;
      case 'apellido':
        state = state.copyWith(apellido: value);
        break;
      case 'email':
        state = state.copyWith(email: value);
        break;
      case 'telefono':
        state = state.copyWith(telefono: value);
        break;
      case 'institucion':
        state = state.copyWith(institucion: value);
        break;
      case 'especialidad':
        state = state.copyWith(especialidad: value);
        break;
      case 'password':
        state = state.copyWith(password: value);
        break;
      case 'idRol':
        state = state.copyWith(idRol: value);
        break;
      case 'estado':
        state = state.copyWith(estado: value);
        break;
    }
  }

  Future<bool> createUser() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.post(
        Uri.parse('https://giit-api-rest.onrender.com/usuarios/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': state.nombre,
          'apellido': state.apellido,
          'email': state.email,
          'telefono': state.telefono,
          'institucion': state.institucion,
          'especialidad': state.especialidad,
          'password': state.password,
          'id_rol': state.idRol,
          'estado': state.estado,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: 'Error al crear usuario: ${response.statusCode}',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error de conexión: $e',
        isLoading: false,
      );
      return false;
    }
  }
}

class CreateUserScreen extends ConsumerWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createUserFormProvider);
    final formNotifier = ref.read(createUserFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Usuario'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información personal
            const Text(
              'Información Personal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => formNotifier.updateField('nombre', value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Apellido *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => formNotifier.updateField('apellido', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => formNotifier.updateField('email', value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => formNotifier.updateField('telefono', value),
            ),
            const SizedBox(height: 24),

            // Información académica
            const Text(
              'Información Académica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Institución *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => formNotifier.updateField('institucion', value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Especialidad *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => formNotifier.updateField('especialidad', value),
            ),
            const SizedBox(height: 24),

            // Configuración de cuenta
            const Text(
              'Configuración de Cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Contraseña *',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (value) => formNotifier.updateField('password', value),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Rol *',
                border: OutlineInputBorder(),
              ),
              value: formState.idRol,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Administrador')),
                DropdownMenuItem(value: 2, child: Text('Investigador')),
              ],
              onChanged: (value) => formNotifier.updateField('idRol', value ?? 2),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Estado *',
                border: OutlineInputBorder(),
              ),
              value: formState.estado,
              items: const [
                DropdownMenuItem(value: 'activo', child: Text('Activo')),
                DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
              ],
              onChanged: (value) => formNotifier.updateField('estado', value ?? 'activo'),
            ),
            const SizedBox(height: 24),

            // Error message
            if (formState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (formState.error != null) const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: formState.isLoading ? null : () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: formState.isLoading
                        ? null
                        : () async {
                            final success = await formNotifier.createUser();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Usuario creado exitosamente')),
                              );
                              context.pop();
                            }
                          },
                    child: formState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Crear Usuario', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 