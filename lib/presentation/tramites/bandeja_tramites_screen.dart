import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';
import 'tramite_cubit.dart';
import 'tramite_detail_screen.dart';

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
      DataCell(Text(t.cut), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TramiteDetailScreen(tramite: t)))),
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

