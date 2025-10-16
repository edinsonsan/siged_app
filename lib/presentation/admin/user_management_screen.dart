import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../auth/auth_cubit.dart';
import '../../domain/models/user.dart';
import '../../domain/models/area.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../widgets/area_dropdown_field.dart';
import 'user_list_cubit.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => UserListCubit(context.read<AdminRepository>())..loadUsers(),
      child: const _UserManagementView(),
    );
  }
}

class _UserManagementView extends StatefulWidget {
  const _UserManagementView();
  @override
  State<_UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<_UserManagementView> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserListCubit, UserListState>(
      listener: (context, state) {
        if (state is UserListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        if (state is UserListSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: BlocBuilder<UserListCubit, UserListState>(
        builder: (context, state) {
          if (state is UserListLoading ||
              state is UserListInitial ||
              state is UserListActionInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserListError) {
            if (context.read<UserListCubit>().state is! UserListLoaded) {
              return Center(child: Text('Error: ${state.message}'));
            }
          }
          if (state is UserListLoaded) {
            final source = _UserDataSource(state.users, context);
            return Column(
              children: [
                // Header with title and create button
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Administración de Usuarios',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Builder(
                              builder: (context) {
                                final authState =
                                    context.read<AuthCubit>().state;
                                final show =
                                    authState is AuthAuthenticated &&
                                    authState.user.rol == UserRole.ADMIN;
                                if (!show) return const SizedBox.shrink();
                                return ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () => _showCreateDialog(context),
                                  icon: const Icon(Icons.person_add),
                                  label: const Text('Crear usuario'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Table card
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: PaginatedDataTable(
                            header: const Text('Usuarios'),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'ID',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nombre',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Email',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Rol',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Área',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Acciones',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            source: source,
                            rowsPerPage: _rowsPerPage,
                            onRowsPerPageChanged: (r) {
                              if (r != null) setState(() => _rowsPerPage = r);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext screenContext) {
    final formKey = GlobalKey<FormState>();
    final nombre = TextEditingController();
    final apellido = TextEditingController();
    final email = TextEditingController();
    // final rol = TextEditingController();
    UserRole selectedRole = UserRole.AREA;
    Area? selectedArea;
    showDialog(
      context: screenContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Crear usuario'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nombre,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.trim().isEmpty ? 'El nombre es obligatorio.' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: apellido,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.trim().isEmpty ? 'El apellido es obligatorio.' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.trim().isEmpty) return 'El email es obligatorio.';
                        if (!value.contains('@') || !value.contains('.')) return 'Formato de email inválido.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<UserRole>(
                      value: selectedRole, // El valor inicial es AREA
                      decoration: InputDecoration(
                        labelText: 'Rol',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items:
                          UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              // Mostrar el rol con la primera letra en mayúscula (ej: Admin)
                              child: Text(
                                role.toString().split('.').last[0].toUpperCase() +
                                    role.toString().split('.').last.substring(1),
                              ),
                            );
                          }).toList(),
                      onChanged: (role) {
                        if (role != null) {
                          selectedRole = role; // Actualiza el rol seleccionado
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    AreaDropdownField(
                      isOptional: true,
                      onChanged: (a) => selectedArea = a,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 1. Validar el formulario
                  if (!formKey.currentState!.validate()) return;
                  
                  // --- Lógica de Generación de Contraseña Temporal ---
                  final rawName = nombre.text.trim().toLowerCase();
                  final rawLastName = apellido.text.trim().toLowerCase();

                  // Normalizar y limpiar (eliminar espacios y tildes si es posible, aunque Dart no tiene una función nativa simple)
                  // Para simplificar, solo quitamos espacios y dejamos minúsculas.
                  final namePart = rawName.replaceAll(' ', '');
                  final lastNamePart = rawLastName.replaceAll(' ', '');

                  // Generar partes para la contraseña
                  final firstInitial = namePart.isNotEmpty ? namePart[0] : '';
                  // Usar las primeras 4 letras del apellido (o menos si es corto)
                  final lastNamePrefix = lastNamePart.length >= 4 ? lastNamePart.substring(0, 4) : lastNamePart;
                  final currentYear = DateTime.now().year.toString();

                  // Contraseña temporal: InicialNombre + PrefijoApellido + Año. Ej: jgonz2025
                  final tempPassword = '$firstInitial$lastNamePrefix$currentYear';
                  // -----------------------------------------------------------------

                  final dto = {
                    'nombre': nombre.text.trim(),
                    'apellido': apellido.text.trim(),
                    'email': email.text.trim(),
                    'rol': selectedRole.name,
                    'area_id': selectedArea?.id,
                    
                    'password': tempPassword,
                    
                  };
                  
                  // Cerrar el diálogo ANTES de iniciar la acción del Cubit (buena práctica)
                  Navigator.of(dialogContext).pop(); 
                  
                  // Llamar a la acción del Cubit
                  screenContext.read<UserListCubit>().createUser(dto);
                  
                  // Opcionalmente, mostrar un SnackBar aquí con la contraseña temporal
                  // para que el administrador la vea antes de que se envíe el email al usuario.
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(
                      content: Text('Usuario creado. Contraseña temporal: $tempPassword.'),
                      duration: const Duration(seconds: 8),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Crear'),
              ),
            ],
          ),
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List<User> data;
  final BuildContext context;
  _UserDataSource(this.data, this.context);

  @override
  DataRow getRow(int index) {
    final u = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(u.id.toString())),
        DataCell(Text('${u.nombre} ${u.apellido}')),
        DataCell(Text(u.email)),
        DataCell(_roleChip(u.rol)),
        DataCell(Text(u.area?.nombre ?? '-')),
        DataCell(
          Builder(
            builder: (cellContext) {
              final authState = context.read<AuthCubit>().state;
              final show =
                  authState is AuthAuthenticated &&
                  authState.user.rol == UserRole.ADMIN;
              if (!show) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(context, u),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, u),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  void _showEditDialog(BuildContext screenContext, User u) {
    final nombre = TextEditingController(text: u.nombre);
    final apellido = TextEditingController(text: u.apellido);
    final email = TextEditingController(text: u.email);
    // final rol = TextEditingController(
    //   text: u.rol.toString().split('.').last.toUpperCase(),
    // );
    UserRole selectedRole = u.rol;
    Area? selectedArea = u.area;
    showDialog(
      context: screenContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Editar usuario'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombre,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apellido,
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserRole>(
                    value:
                        selectedRole, // El valor inicial es el rol del usuario
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role.toString().split('.').last[0].toUpperCase() +
                                  role.toString().split('.').last.substring(1),
                            ),
                          );
                        }).toList(),
                    onChanged: (role) {
                      if (role != null) {
                        selectedRole = role; // Actualiza el rol seleccionado
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  AreaDropdownField(
                    isOptional: true,
                    initialValueId: u.area?.id,
                    onChanged: (a) => selectedArea = a,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final dto = {
                    'nombre': nombre.text.trim(),
                    'apellido': apellido.text.trim(),
                    'email': email.text.trim(),
                    // 'rol': rol.text.trim(),
                    'rol': selectedRole.name,
                    'area_id': selectedArea?.id.toInt(),
                  };
                  context.read<UserListCubit>().updateUser(u.id, dto);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Widget _roleChip(UserRole r) {
    Color color;
    switch (r) {
      case UserRole.ADMIN:
        color = Colors.purple.shade600;
        break;
      case UserRole.MESA_PARTES:
        color = Colors.teal.shade600;
        break;
      case UserRole.AREA:
        color = Colors.blue.shade600;
        break;
      case UserRole.AUDITOR:
        color = Colors.orange.shade700;
        break;
    }
    return Chip(
      backgroundColor: color.withAlpha((0.12 * 255).toInt()),
      label: Text(
        r.toString().split('.').last[0].toUpperCase() +
            r.toString().split('.').last.substring(1),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _confirmDelete(BuildContext screenContext, User u) {
    showDialog(
      context: screenContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Eliminar usuario'),
            content: Text('¿Eliminar usuario ${u.nombre} ${u.apellido}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<UserListCubit>().deleteUser(u.id);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
