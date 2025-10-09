import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/admin_repository.dart';
import 'user_list_cubit.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserListCubit(context.read<AdminRepository>())..loadUsers(),
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
    return BlocBuilder<UserListCubit, UserListState>(builder: (context, state) {
      if (state is UserListLoading || state is UserListInitial) return const Center(child: CircularProgressIndicator());
      if (state is UserListError) return Center(child: Text('Error: ${state.message}'));
      if (state is UserListLoaded) {
        final source = _UserDataSource(state.users, context);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Administración de Usuarios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => _showCreateDialog(context),
                  child: const Text('Crear usuario'),
                )
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: PaginatedDataTable(
                  header: const Text('Usuarios'),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Rol')),
                    DataColumn(label: Text('Área')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  source: source,
                  rowsPerPage: _rowsPerPage,
                  onRowsPerPageChanged: (r) {
                    if (r != null) setState(() => _rowsPerPage = r);
                  },
                ),
              ),
            )
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  void _showCreateDialog(BuildContext context) {
    final nombre = TextEditingController();
    final apellido = TextEditingController();
    final email = TextEditingController();
    final rol = TextEditingController();
    final areaId = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear usuario'),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: apellido, decoration: const InputDecoration(labelText: 'Apellido')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: rol, decoration: const InputDecoration(labelText: 'Rol (ADMIN|MESA_PARTES|AREA|AUDITOR)')),
            TextField(controller: areaId, decoration: const InputDecoration(labelText: 'Area ID (opcional)'), keyboardType: TextInputType.number),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final dto = {
                'nombre': nombre.text.trim(),
                'apellido': apellido.text.trim(),
                'email': email.text.trim(),
                'rol': rol.text.trim(),
                if (areaId.text.isNotEmpty) 'areaId': int.tryParse(areaId.text.trim()),
                // Password may be required by the API - set a default or ask user
                'password': 'changeme123'
              };
              context.read<UserListCubit>().createUser(dto);
              Navigator.of(context).pop();
            },
            child: const Text('Crear'),
          )
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
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(u.id.toString())),
      DataCell(Text('${u.nombre} ${u.apellido}')),
      DataCell(Text(u.email)),
      DataCell(Text(u.rol.toString().split('.').last)),
      DataCell(Text(u.area?.nombre ?? '-')),
      DataCell(Row(children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(context, u)),
        IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(context, u)),
      ])),
    ]);
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
    final rol = TextEditingController(text: u.rol.toString().split('.').last.toUpperCase());
  final areaId = TextEditingController(text: u.area != null ? u.area!.id.toString() : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar usuario'),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: apellido, decoration: const InputDecoration(labelText: 'Apellido')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: rol, decoration: const InputDecoration(labelText: 'Rol (ADMIN|MESA_PARTES|AREA|AUDITOR)')),
            TextField(controller: areaId, decoration: const InputDecoration(labelText: 'Area ID (opcional)'), keyboardType: TextInputType.number),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final dto = {
                'nombre': nombre.text.trim(),
                'apellido': apellido.text.trim(),
                'email': email.text.trim(),
                'rol': rol.text.trim(),
                if (areaId.text.isNotEmpty) 'areaId': int.tryParse(areaId.text.trim()),
              };
              context.read<UserListCubit>().updateUser(u.id, dto);
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, User u) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar usuario ${u.nombre} ${u.apellido}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<UserListCubit>().deleteUser(u.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }
}
