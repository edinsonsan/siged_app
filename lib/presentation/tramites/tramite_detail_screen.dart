import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../domain/models/tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';
import 'detail_tramite_cubit.dart';

class TramiteDetailScreen extends StatelessWidget {
  final TramiteModel tramite;

  const TramiteDetailScreen({super.key, required this.tramite});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailTramiteCubit(context.read<TramiteRepository>())..loadTramite(tramite),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trámite ${tramite.cut}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<DetailTramiteCubit, DetailTramiteState>(
            listener: (context, state) {
              if (state is DetailTramiteError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
              if (state is DetailTramiteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); 
              }
            },
            builder: (context, state) {
              if (state is DetailTramiteLoading || state is DetailTramiteInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DetailTramiteLoaded) {
                return _buildDetail(context, state);
              }
              if (state is DetailTramiteActionInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DetailTramiteError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, DetailTramiteLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asunto: ${state.tramite.asunto}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Remitente: ${state.tramite.remitenteNombre}'),
          const SizedBox(height: 8),
          Text('Área actual: ${state.tramite.areaActual ?? 'N/A'}'),
          const SizedBox(height: 16),
          Text('Historial', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...state.historial.map((h) => TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: state.historial.first == h,
                isLast: state.historial.last == h,
                indicatorStyle: const IndicatorStyle(width: 20, color: Colors.blue),
                afterLineStyle: const LineStyle(color: Colors.grey),
                endChild: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${h.usuario != null ? '${h.usuario!.nombre} ${h.usuario!.apellido}' : 'Sistema'} - ${h.fecha}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(h.comentario),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Text('Adjuntos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('No hay adjuntos implementados aún.'),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showDerivarDialog(context, state.tramite),
                child: const Text('Derivar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _confirmFinalizar(context, state.tramite),
                child: const Text('Finalizar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showObservarDialog(context, state.tramite),
                child: const Text('Observar'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showDerivarDialog(BuildContext context, TramiteModel tramite) {
    final areaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Derivar trámite'),
        content: TextField(
          controller: areaController,
          decoration: const InputDecoration(labelText: 'ID Área destino'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final toAreaId = int.tryParse(areaController.text);
              if (toAreaId != null) {
                context.read<DetailTramiteCubit>().derivar(tramite.id, toAreaId);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Derivar'),
          )
        ],
      ),
    );
  }

  void _showObservarDialog(BuildContext context, TramiteModel tramite) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Observar trámite'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(labelText: 'Comentario'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                context.read<DetailTramiteCubit>().observar(tramite.id, comment);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Enviar'),
          )
        ],
      ),
    );
  }

  void _confirmFinalizar(BuildContext context, TramiteModel tramite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar trámite'),
        content: const Text('¿Seguro que desea finalizar este trámite?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<DetailTramiteCubit>().finalizar(tramite.id);
              Navigator.of(context).pop();
            },
            child: const Text('Finalizar'),
          )
        ],
      ),
    );
  }
}
