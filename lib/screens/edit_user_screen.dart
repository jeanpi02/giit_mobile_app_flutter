import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

// Estado del formulario de edición de usuario
class EditUserFormState {
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

  EditUserFormState({
    this.nombre = '',
    this.apellido = '',
    this.email = '',
    this.telefono = '',
    this.institucion = '',
    this.especialidad = '',
    this.password = '',
    this.idRol = 2,
    this.estado = 'activo',
    this.isLoading = false,
    this.error,
  });

  EditUserFormState copyWith({
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
    return EditUserFormState(
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

// Provider para el formulario de edición
final editUserFormProvider = StateNotifierProvider.family<EditUserFormNotifier, EditUserFormState, User>((ref, user) {
  return EditUserFormNotifier(user);
});

class EditUserFormNotifier extends StateNotifier<EditUserFormState> {
  EditUserFormNotifier(User user) : super(EditUserFormState(
    nombre: user.nombre,
    apellido: user.apellido,
    email: user.email,
    telefono: user.telefono,
    institucion: user.institucion,
    especialidad: user.especialidad,
    password: user.password ?? '',
    idRol: user.idRol,
    estado: user.estado,
  ));

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

  Future<bool> updateUser(int userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Map<String, dynamic> body = {
        'nombre': state.nombre,
        'apellido': state.apellido,
        'email': state.email,
        'telefono': state.telefono,
        'institucion': state.institucion,
        'especialidad': state.especialidad,
        'id_rol': state.idRol,
        'estado': state.estado,
      };

      // Solo incluir password si no está vacío
      if (state.password.isNotEmpty) {
        body['password'] = state.password;
      }

      final response = await http.put(
        Uri.parse('https://giit-api-rest.onrender.com/usuarios/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: 'Error al actualizar usuario: ${response.statusCode}',
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

class EditUserScreen extends ConsumerWidget {
  final User user;
  
  const EditUserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(editUserFormProvider(user));
    final formNotifier = ref.read(editUserFormProvider(user).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
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
                    initialValue: formState.nombre,
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
                    initialValue: formState.apellido,
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
              initialValue: formState.email,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => formNotifier.updateField('email', value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: formState.telefono,
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
              initialValue: formState.institucion,
              decoration: const InputDecoration(
                labelText: 'Institución *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => formNotifier.updateField('institucion', value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: formState.especialidad,
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
                labelText: 'Nueva Contraseña (opcional)',
                border: OutlineInputBorder(),
                helperText: 'Dejar vacío para mantener la contraseña actual',
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
                            final success = await formNotifier.updateUser(user.idUsuario);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Usuario actualizado exitosamente')),
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
                        : const Text('Actualizar Usuario', style: TextStyle(color: Colors.white)),
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