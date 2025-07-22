class User {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String institucion;
  final String especialidad;
  final String? fotoPerfil;
  final int idRol;
  final String estado;
  final String? password;
  final DateTime? fechaRegistro;
  final DateTime? ultimoAcceso;
  final Rol? rol;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.institucion,
    required this.especialidad,
    this.fotoPerfil,
    required this.idRol,
    required this.estado,
    this.password,
    this.fechaRegistro,
    this.ultimoAcceso,
    this.rol,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        idUsuario: json['id_usuario'] ?? 0,
        nombre: json['nombre'] ?? '',
        apellido: json['apellido'] ?? '',
        email: json['email'] ?? '',
        telefono: json['telefono'] ?? '',
        institucion: json['institucion'] ?? '',
        especialidad: json['especialidad'] ?? '',
        fotoPerfil: json['foto_perfil'] as String?,
        idRol: json['id_rol'] ?? 0,
        estado: json['estado'] ?? '',
        password: json['password'] as String?,
        fechaRegistro: json['fecha_registro'] != null ? DateTime.parse(json['fecha_registro']) : null,
        ultimoAcceso: json['ultimo_acceso'] != null && json['ultimo_acceso'] != '' ? DateTime.tryParse(json['ultimo_acceso']) : null,
        rol: json['rol'] != null ? Rol.fromJson(json['rol']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'institucion': institucion,
        'especialidad': especialidad,
        'foto_perfil': fotoPerfil,
        'id_rol': idRol,
        'estado': estado,
        'password': password,
        'fecha_registro': fechaRegistro?.toIso8601String(),
        'ultimo_acceso': ultimoAcceso?.toIso8601String(),
        'rol': rol?.toJson(),
      };
}

class Rol {
  final int idRol;
  final String nombreRol;
  final String descripcion;

  Rol({required this.idRol, required this.nombreRol, required this.descripcion});

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
        idRol: json['id_rol'] ?? 0,
        nombreRol: json['nombre_rol'] ?? '',
        descripcion: json['descripcion'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id_rol': idRol,
        'nombre_rol': nombreRol,
        'descripcion': descripcion,
      };
} 