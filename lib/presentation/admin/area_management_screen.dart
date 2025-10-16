import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../auth/auth_cubit.dart';
import '../../domain/models/user.dart';
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
            FadeInDown(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Administración de Áreas', style: Theme.of(context).textTheme.headlineMedium),
                      Builder(builder: (context) {
                        final authState = context.read<AuthCubit>().state;
                        final show = authState is AuthAuthenticated && authState.user.rol == UserRole.ADMIN;
                        if (!show) return const SizedBox.shrink();
                        return ElevatedButton.icon(
                          onPressed: () => _showCreateDialog(context),
                          icon: const Icon(Icons.add_business),
                          label: const Text('Crear Área'),
                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        );
                      })
                    ]),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ListView.builder(
                  itemCount: state.areas.length,
                  itemBuilder: (context, i) {
                    final a = state.areas[i];
                    return FadeInLeft(
                      duration: Duration(milliseconds: 200 + (i * 30)),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.08 * 255).toInt()), child: Text(a.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          title: Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(a.descripcion ?? ''),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            Builder(builder: (context) {
                              final authState = context.read<AuthCubit>().state;
                              final show = authState is AuthAuthenticated && authState.user.rol == UserRole.ADMIN;
                              if (!show) return const SizedBox.shrink();
                              return Row(children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), tooltip: 'Editar', onPressed: () => _showEditDialog(context, a)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Eliminar', onPressed: () => _confirmDelete(context, a)),
                              ]);
                            })
                          ]),
                        ),
                      ),
                    );
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

  void _showCreateDialog(BuildContext screenContext) {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();

    showDialog(
      context: screenContext, // Usamos el contexto que sí tiene el Cubit como padre
      builder: (dialogContext) => AlertDialog( // El builder recibe un nuevo contexto (dialogContext)
        title: const Text('Crear Área'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombre, decoration: InputDecoration(labelText: 'Nombre', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 8),
          TextField(controller: descripcion, decoration: InputDecoration(labelText: 'Descripción', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            // **AQUÍ ESTÁ LA CORRECCIÓN CLAVE**
            // Usamos el 'screenContext' original para llamar a read<Cubit>
            onPressed: () {
              final dto = {'nombre': nombre.text.trim(), 'descripcion': descripcion.text.trim()};
              
              // Usamos screenContext para acceder al Cubit que está más arriba en el árbol.
              screenContext.read<AreaListCubit>().createArea(dto);
              
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Crear'),
          )
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext screenContext, area) {
    final nombre = TextEditingController(text: area.nombre);
    final descripcion = TextEditingController(text: area.descripcion ?? '');

    showDialog(
      context: screenContext, // Usamos el contexto padre para abrir el diálogo
      builder: (dialogContext) => AlertDialog( // El builder genera un nuevo contexto: dialogContext
        title: const Text('Editar Área'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombre, decoration: InputDecoration(labelText: 'Nombre', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 8),
          TextField(controller: descripcion, decoration: InputDecoration(labelText: 'Descripción', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final dto = {'nombre': nombre.text.trim(), 'descripcion': descripcion.text.trim()};
              
              screenContext.read<AreaListCubit>().updateArea(area.id, dto);
              
              Navigator.of(dialogContext).pop(); // Cerramos con el context del diálogo
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext screenContext, area) {
    showDialog(
      context: screenContext, // Usamos el contexto padre para abrir el diálogo
      builder: (dialogContext) => AlertDialog( // El builder genera un nuevo contexto: dialogContext
        title: const Text('Eliminar Área'),
        content: Text('¿Eliminar área ${area.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              // **CORRECCIÓN CLAVE:** Usamos screenContext para acceder al Cubit.
              screenContext.read<AreaListCubit>().deleteArea(area.id);
              
              Navigator.of(dialogContext).pop(); // Cerramos con el context del diálogo
            },
            child: const Text('Eliminar'),
          )
        ],
      ),
    );
  }
}
