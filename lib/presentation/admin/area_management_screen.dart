import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'area_list_cubit.dart';

class AreaManagementScreen extends StatelessWidget {
  const AreaManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AreaListCubit(context.read<AdminRepository>())..loadAreas(),
      child: const _AreaManagementView(),
    );
  }
}

class _AreaManagementView extends StatefulWidget {
  const _AreaManagementView();
  @override
  State<_AreaManagementView> createState() => _AreaManagementViewState();
}

class _AreaManagementViewState extends State<_AreaManagementView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AreaListCubit, AreaListState>(builder: (context, state) {
      if (state is AreaListLoading || state is AreaListInitial) return const Center(child: CircularProgressIndicator());
      if (state is AreaListError) return Center(child: Text('Error: ${state.message}'));
      if (state is AreaListLoaded) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Administración de Áreas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: () => _showCreateDialog(context), child: const Text('Crear Área'))
              ]),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.areas.length,
                itemBuilder: (context, i) {
                  final a = state.areas[i];
                  return ListTile(
                    title: Text(a.nombre),
                    subtitle: Text(a.descripcion ?? ''),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(context, a)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(context, a)),
                    ]),
                  );
                },
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
    final descripcion = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Área'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(controller: descripcion, decoration: const InputDecoration(labelText: 'Descripción')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final dto = {'nombre': nombre.text.trim(), 'descripcion': descripcion.text.trim()};
              context.read<AreaListCubit>().createArea(dto);
              Navigator.of(context).pop();
            },
            child: const Text('Crear'),
          )
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, area) {
    final nombre = TextEditingController(text: area.nombre);
    final descripcion = TextEditingController(text: area.descripcion ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Área'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(controller: descripcion, decoration: const InputDecoration(labelText: 'Descripción')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final dto = {'nombre': nombre.text.trim(), 'descripcion': descripcion.text.trim()};
              context.read<AreaListCubit>().updateArea(area.id, dto);
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Área'),
        content: Text('¿Eliminar área ${area.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AreaListCubit>().deleteArea(area.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }
}
