import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';
import 'tramite_cubit.dart';
import 'tramite_register_screen.dart';
import 'package:go_router/go_router.dart';
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
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por CUT o Asunto'),
                  onSubmitted: (v) => context.read<TramiteCubit>().applySearch(v.isEmpty ? null : v),
                ),
              ),
              const SizedBox(width: 12),
              // Show Nuevo Trámite only for ADMIN and MESA_PARTES
              Builder(builder: (context) {
                final authState = context.read<AuthCubit>().state;
                final showNuevo = authState is AuthAuthenticated && (authState.user.rol == UserRole.admin || authState.user.rol == UserRole.mesaPartes);
                if (!showNuevo) return const SizedBox.shrink();
                return ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TramiteRegisterScreen())), icon: const Icon(Icons.add), label: const Text('Nuevo Trámite'));
              }),
              const SizedBox(width: 12),
              DropdownButton<String?>(
                value: _selectedEstado,
                hint: const Text('Estado'),
                items: [null, 'RECIBIDO', 'EN_PROCESO', 'OBSERVADO', 'FINALIZADO']
                    .map((e) => DropdownMenuItem<String?>(value: e, child: Text(e ?? 'Todos')))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedEstado = v);
                  context.read<TramiteCubit>().applyEstado(v);
                },
              ),
              const SizedBox(width: 12),
              // Row(children: [
              //   Checkbox(value: _showAll, onChanged: (v) {
              //     setState(() => _showAll = v ?? false);
              //     context.read<TramiteCubit>().setShowAll(_showAll);
              //   }),
              //   const Text('Mostrar todos')
              // ])
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<TramiteCubit, TramiteState>(builder: (context, state) {
            if (state is TramiteLoading) return const Center(child: CircularProgressIndicator());
            if (state is TramiteError) return Center(child: Text('Error: ${state.message}'));
            if (state is TramiteLoaded) {
              final source = _TramiteDataSource(state.list, context);
              return SingleChildScrollView(
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
    Color estadoColor;
    switch (t.estado) {
      case TramiteEstado.finalizado:
        estadoColor = Colors.green;
        break;
      case TramiteEstado.enProceso:
        estadoColor = Colors.yellow.shade700;
        break;
      case TramiteEstado.observado:
        estadoColor = Colors.red;
        break;
      case TramiteEstado.recibido:
        estadoColor = Colors.grey;
        break;
    }

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(t.cut), onTap: () => GoRouter.of(context).go('/home/bandeja/\${t.id}')),
      DataCell(Text(t.asunto)),
      DataCell(Text(t.remitenteNombre)),
      DataCell(Text(t.fechaCreacion)),
      DataCell(Text(t.areaActual?.nombre ?? '-')),
      DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: estadoColor, borderRadius: BorderRadius.circular(8)), child: Text(t.estado.toString().split('.').last))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

