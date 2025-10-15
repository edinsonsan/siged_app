import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../auth/auth_cubit.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/admin_repository.dart';
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
    return BlocBuilder<UserListCubit, UserListState>(
      builder: (context, state) {
        if (state is UserListLoading || state is UserListInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserListError) {
          return Center(child: Text('Error: ${state.message}'));
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
                              final authState = context.read<AuthCubit>().state;
                              final show =
                                  authState is AuthAuthenticated &&
                                  authState.user.rol == UserRole.admin;
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
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nombre = TextEditingController();
    final apellido = TextEditingController();
    final email = TextEditingController();
    final rol = TextEditingController();
    final areaId = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Crear usuario'),
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
                  TextField(
                    controller: rol,
                    decoration: InputDecoration(
                      labelText: 'Rol (ADMIN|MESA_PARTES|AREA|AUDITOR)',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: areaId,
                    decoration: InputDecoration(
                      labelText: 'Area ID (opcional)',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final dto = {
                    'nombre': nombre.text.trim(),
                    'apellido': apellido.text.trim(),
                    'email': email.text.trim(),
                    'rol': rol.text.trim(),
                    if (areaId.text.isNotEmpty)
                      'areaId': int.tryParse(areaId.text.trim()),
                    // Password may be required by the API - set a default or ask user
                    'password': 'changeme123',
                  };
                  context.read<UserListCubit>().createUser(dto);
                  Navigator.of(context).pop();
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
            builder: (context) {
              final authState = context.read<AuthCubit>().state;
              final show =
                  authState is AuthAuthenticated &&
                  authState.user.rol == UserRole.admin;
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

  void _showEditDialog(BuildContext context, User u) {
    final nombre = TextEditingController(text: u.nombre);
    final apellido = TextEditingController(text: u.apellido);
    final email = TextEditingController(text: u.email);
    final rol = TextEditingController(
      text: u.rol.toString().split('.').last.toUpperCase(),
    );
    final areaId = TextEditingController(
      text: u.area != null ? u.area!.id.toString() : '',
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  TextField(
                    controller: rol,
                    decoration: InputDecoration(
                      labelText: 'Rol (ADMIN|MESA_PARTES|AREA|AUDITOR)',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: areaId,
                    decoration: InputDecoration(
                      labelText: 'Area ID (opcional)',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final dto = {
                    'nombre': nombre.text.trim(),
                    'apellido': apellido.text.trim(),
                    'email': email.text.trim(),
                    'rol': rol.text.trim(),
                    if (areaId.text.isNotEmpty)
                      'areaId': int.tryParse(areaId.text.trim()),
                  };
                  context.read<UserListCubit>().updateUser(u.id, dto);
                  Navigator.of(context).pop();
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
      case UserRole.admin:
        color = Colors.purple.shade600;
        break;
      case UserRole.mesaPartes:
        color = Colors.teal.shade600;
        break;
      case UserRole.area:
        color = Colors.blue.shade600;
        break;
      case UserRole.auditor:
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

  void _confirmDelete(BuildContext context, User u) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar usuario'),
            content: Text('¿Eliminar usuario ${u.nombre} ${u.apellido}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<UserListCubit>().deleteUser(u.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
