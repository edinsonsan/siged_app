import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../auth/auth_cubit.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../domain/models/user.dart';
import '../../domain/models/area.dart';

import '../../domain/models/tramite_model.dart';
import '../../domain/repositories/tramite_repository.dart';
import 'detail_tramite_cubit.dart';
import '../../widgets/area_dropdown_field.dart';

class TramiteDetailScreen extends StatefulWidget {
  final TramiteModel? tramite;
  final int? id;

  const TramiteDetailScreen({super.key, this.tramite, this.id});

  /// Helper to construct from route id
  factory TramiteDetailScreen.fromId({int? id}) => TramiteDetailScreen(id: id);

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  TramiteModel? _tramite;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tramite = widget.tramite;
    if (_tramite != null) {
      _loading = false;
    } else if (widget.id != null) {
      _fetchById(widget.id!);
    } else {
      _loading = false;
    }
  }

  Future<void> _fetchById(int id) async {
    try {
      final repo = context.read<TramiteRepository>();
      final t = await repo.getTramiteById(id);
      if (!mounted) return;
      setState(() {
        _tramite = t;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar trámite: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_tramite == null) return const Scaffold(body: Center(child: Text('Trámite no encontrado')));

    final tramite = _tramite!;

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
    final df = DateFormat.yMMMMd(Localizations.localeOf(context).toString());
    Color statusColor(TramiteEstado e) {
      if (e == TramiteEstado.finalizado) return Colors.green.shade600;
      if (e == TramiteEstado.enProceso) return Colors.orange.shade700;
      if (e == TramiteEstado.observado) return Colors.red.shade600;
      return Colors.blue.shade600; // recibido or fallback
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 350),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with key details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CUT ${state.tramite.cut}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(state.tramite.asunto, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(Icons.person, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Text(state.tramite.remitenteNombre, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 12),
                            Icon(Icons.business, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 6),
                            Text(state.tramite.areaActual?.nombre ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium),
                          ])
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Chip(
                          backgroundColor: statusColor(state.tramite.estado),
                          label: Text(state.tramite.estado.toString().split('.').last.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 8),
                        Text('Creado: ${df.format(state.tramite.fechaCreacion)}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Historial
            FadeInLeft(duration: const Duration(milliseconds: 300), child: Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Text('Historial', style: Theme.of(context).textTheme.titleMedium))),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: state.historial.map((h) {
                    final isFirst = state.historial.first == h;
                    final isLast = state.historial.last == h;
                    final parsedDate = DateTime.tryParse(h.fecha) ?? DateTime.now();
                    return TimelineTile(
                      alignment: TimelineAlign.start,
                      isFirst: isFirst,
                      isLast: isLast,
                      indicatorStyle: IndicatorStyle(
                        width: 24,
                        color: isLast ? statusColor(state.tramite.estado) : Colors.grey.shade400,
                        indicator: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isLast ? statusColor(state.tramite.estado) : Colors.white, border: Border.all(color: isLast ? statusColor(state.tramite.estado) : Colors.grey.shade400, width: 2)),
                          child: Center(child: Icon(isLast ? Icons.check : Icons.circle, size: isLast ? 16 : 8, color: isLast ? Colors.white : Colors.grey.shade400)),
                        ),
                      ),
                      afterLineStyle: LineStyle(color: Colors.grey.shade300, thickness: 2),
                      endChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${h.usuario != null ? '${h.usuario!.nombre} ${h.usuario!.apellido}' : 'Sistema'} • ${DateFormat.yMMMd().add_jm().format(parsedDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(h.comentario),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Adjuntos
            FadeInLeft(duration: const Duration(milliseconds: 300), child: Padding(padding: const EdgeInsets.symmetric(vertical: 6.0), child: Text('Adjuntos', style: Theme.of(context).textTheme.titleMedium))),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: state.tramite.documentosAdjuntos.isEmpty
                    ? Padding(padding: const EdgeInsets.all(12.0), child: Text('No hay documentos adjuntos para este trámite.', style: Theme.of(context).textTheme.bodyMedium))
                    : Column(children: state.tramite.documentosAdjuntos.map((doc) => _attachmentItem(doc: doc, onOpen: () => _launchUrl(doc.urlArchivo))).toList()),
              ),
            ),

            const SizedBox(height: 18),

            // Actions bar
            Builder(builder: (context) {
              final authState = context.read<AuthCubit>().state;
              final canAct = authState is AuthAuthenticated && (authState.user.rol == UserRole.ADMIN || authState.user.rol == UserRole.AREA);
              if (!canAct) return const SizedBox.shrink();
              return Row(
                children: [
                  ElevatedButton.icon(onPressed: () => _showDerivarDialog(context, state.tramite), icon: const Icon(Icons.send), label: const Text('Derivar')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(onPressed: () => _confirmFinalizar(context, state.tramite), icon: const Icon(Icons.check_circle), label: const Text('Finalizar')),
                  const SizedBox(width: 8),
                  TextButton.icon(onPressed: () => _showObservarDialog(context, state.tramite), icon: const Icon(Icons.visibility), label: const Text('Observar')),
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem({required dynamic doc, required VoidCallback onOpen}) {
    // doc is a DocumentoAdjunto-like object; keep dynamic to avoid tight coupling
    final title = (doc.tipo != null) ? 'Documento (${doc.tipo})' : 'Adjunto';
    final uploaded = doc.fechaSubida != null ? DateTime.tryParse(doc.fechaSubida.toString()) : null;
    final subtitle = uploaded != null ? DateFormat.yMMMd().format(uploaded) : null;
    final isPdf = (doc.tipo ?? '').toString().toLowerCase().contains('pdf');
    return ListTile(
      leading: CircleAvatar(backgroundColor: isPdf ? Colors.red.shade100 : Colors.blue.shade50, child: Icon(isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file, color: isPdf ? Colors.red : Colors.blue)),
      title: Text(title, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
      subtitle: subtitle != null ? Text('Subido: $subtitle', style: Theme.of(context).textTheme.bodySmall) : null,
      trailing: IconButton(icon: const Icon(Icons.open_in_new), onPressed: onOpen),
      dense: true,
      onTap: onOpen,
    );
  }

  void _showDerivarDialog(BuildContext context, TramiteModel tramite) {
    Area? selectedArea;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Derivar trámite'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AreaDropdownField(
                isOptional: false,
                onChanged: (a) => setState(() => selectedArea = a),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (selectedArea != null) {
                  final toAreaId = selectedArea!.id.toInt();
                  final authState = context.read<AuthCubit>().state;
                  final int? userId = authState is AuthAuthenticated ? authState.user.id.toInt() : null;
                  context.read<DetailTramiteCubit>().derivar(tramite.id.toInt(), toAreaId, userId: userId);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Derivar'),
            )
          ],
        ),
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
                final authState = context.read<AuthCubit>().state;
                if (authState is! AuthAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión para observar')));
                  return;
                }
                final int userId = authState.user.id.toInt();
                context.read<DetailTramiteCubit>().observar(tramite.id.toInt(), comment, userId);
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
              final authState = context.read<AuthCubit>().state;
              if (authState is! AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe iniciar sesión para finalizar')));
                return;
              }
              final int userId = authState.user.id.toInt();
              context.read<DetailTramiteCubit>().finalizar(tramite.id.toInt(), userId);
              Navigator.of(context).pop();
            },
            child: const Text('Finalizar'),
          )
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento.')),
      );
    }
  }
}
