import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';
import 'tramite_cubit.dart';
import 'tramite_register_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../auth/auth_cubit.dart';
import '../../domain/models/user.dart';

class BandejaTramitesScreen extends StatelessWidget {
  const BandejaTramitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TramiteCubit(RepositoryProvider.of<TramiteRepository>(context)),
      child: const _BandejaView(),
    );
  }
}

class _BandejaView extends StatefulWidget {
  const _BandejaView();

  @override
  State<_BandejaView> createState() => _BandejaViewState();
}

class _BandejaViewState extends State<_BandejaView> {
  final _searchController = TextEditingController();
  String? _selectedEstado;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  // final bool _showAll = false;

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Buscar por CUT o Asunto',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (v) => context.read<TramiteCubit>().applySearch(v.isEmpty ? null : v),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Estado filter styled
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedEstado,
                          hint: const Text('Estado'),
                          items: [null, 'RECIBIDO', 'EN_PROCESO', 'OBSERVADO', 'FINALIZADO']
                              .map((e) => DropdownMenuItem<String?>(value: e, child: Text(e == null ? 'Todos' : _estadoLabel(e))))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedEstado = v);
                            context.read<TramiteCubit>().applyEstado(v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nuevo Trámite (role-based)
                    Builder(builder: (context) {
                      final authState = context.read<AuthCubit>().state;
                      final showNuevo = authState is AuthAuthenticated && (authState.user.rol == UserRole.ADMIN || authState.user.rol == UserRole.MESA_PARTES);
                      if (!showNuevo) return const SizedBox.shrink();
                      final tramiteCubit = context.read<TramiteCubit>();
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value( // reuse the Cubit for the register screen
                              value: tramiteCubit,
                              child: const TramiteRegisterScreen(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Nuevo Trámite', style: TextStyle(color: Colors.white)),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<TramiteCubit, TramiteState>(builder: (context, state) {
            if (state is TramiteLoading) return const Center(child: CircularProgressIndicator());
            if (state is TramiteError) return Center(child: Text('Error: ${state.message}'));
            if (state is TramiteLoaded) {
              final authState = context.read<AuthCubit>().state;
              List<TramiteModel> filteredList = state.list;
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                if (user.rol == UserRole.AREA && user.area != null) {
                  filteredList = state.list.where((t) => t.areaActual?.id == user.area!.id).toList();
                }
              }
              final source = _TramiteDataSource(filteredList, context);
              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: SingleChildScrollView(
                      child: PaginatedDataTable(
                        header: const Text('Bandeja de Trámites'),
                        columns: const [
                          DataColumn(label: Text('CUT')),
                          DataColumn(label: Text('Asunto')),
                          DataColumn(label: Text('Remitente')),
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Área Actual')),
                          DataColumn(label: Text('Estado')),
                        ],
                        source: source,
                        rowsPerPage: _rowsPerPage,
                        onRowsPerPageChanged: (r) {
                          if (r != null) setState(() => _rowsPerPage = r);
                        },
                        availableRowsPerPage: const [5, 10, 20],
                        onPageChanged: (firstRowIndex) {
                          context.read<TramiteCubit>().changePage(_rowsPerPage, firstRowIndex);
                        },
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ),
      ],
    );
  }
}

class _TramiteDataSource extends DataTableSource {
  final List<TramiteModel> data;
  final BuildContext context;

  _TramiteDataSource(this.data, this.context);

  @override
  DataRow getRow(int index) {
    final t = data[index];
    Color estadoColor() {
      if (t.estado == TramiteEstado.finalizado) return Colors.green.shade700;
      if (t.estado == TramiteEstado.enProceso) return Colors.orange.shade700;
      if (t.estado == TramiteEstado.observado) return Colors.red.shade700;
      return Colors.blue.shade700;
    }

    return DataRow.byIndex(index: index, cells: [
      DataCell(
        Text(t.cut, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          GoRouter.of(context).go('/home/bandeja/${t.id}');
        },
      ),
      DataCell(Text(t.asunto)),
      DataCell(Text(t.remitenteNombre)),
      DataCell(Text(t.fechaCreacion.toLocal().toString().split(' ').first)),
      DataCell(Text(t.areaActual?.nombre ?? '-')),
      DataCell(
        Chip(
          backgroundColor: estadoColor().withAlpha((0.15 * 255).toInt()),
          label: Text(
            _estadoLabel(t.estado.toString().split('.').last),
            style: TextStyle(color: estadoColor(), fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

String _estadoLabel(String raw) {
  if (raw.isEmpty) return '';
  final lower = raw.toLowerCase();
  // convert snake_case or uppercase to Capitalized
  final parts = lower.split(RegExp(r'[_\s]'));
  return parts.map((p) => '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
}

