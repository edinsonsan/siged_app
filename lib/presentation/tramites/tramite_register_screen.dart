import 'package:file_picker/file_picker.dart';
import 'tramite_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/tramite_repository.dart';
import '../auth/auth_cubit.dart';

class TramiteRegisterScreen extends StatefulWidget {
  const TramiteRegisterScreen({super.key});

  @override
  State<TramiteRegisterScreen> createState() => _TramiteRegisterScreenState();
}

class _TramiteRegisterScreenState extends State<TramiteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cut = TextEditingController();
  final _asunto = TextEditingController();
  final _tipoDocumento = TextEditingController();
  final _folios = TextEditingController();
  final _remitenteNombre = TextEditingController();
  final _remitenteDocumento = TextEditingController();
  final _remitenteDireccion = TextEditingController();
  final _remitenteEmail = TextEditingController();
  final _remitenteTelefono = TextEditingController();

  PlatformFile? _pickedFile;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Trámite')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(controller: _cut, decoration: const InputDecoration(labelText: 'CUT'), validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null),
              TextFormField(controller: _asunto, decoration: const InputDecoration(labelText: 'Asunto'), validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null),
              TextFormField(controller: _tipoDocumento, decoration: const InputDecoration(labelText: 'Tipo Documento'), validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null),
              TextFormField(controller: _folios, decoration: const InputDecoration(labelText: 'Folios'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              const Text('Remitente', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: _remitenteNombre, decoration: const InputDecoration(labelText: 'Nombre')),
              TextFormField(controller: _remitenteDocumento, decoration: const InputDecoration(labelText: 'DNI / RUC')),
              TextFormField(controller: _remitenteDireccion, decoration: const InputDecoration(labelText: 'Dirección')),
              TextFormField(controller: _remitenteEmail, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              TextFormField(controller: _remitenteTelefono, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              Row(children: [
                ElevatedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.attach_file), label: const Text('Adjuntar documento')),
                const SizedBox(width: 12),
                Expanded(child: Text(_pickedFile?.name ?? 'Ningún archivo seleccionado'))
              ]),
              const SizedBox(height: 24),
              Row(children: [
                ElevatedButton(onPressed: _submitting ? null : _submit, child: _submitting ? const CircularProgressIndicator() : const Text('Registrar')),
                const SizedBox(width: 8),
                TextButton(onPressed: _submitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancelar'))
              ])
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // show snackbar indicating required fields
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor complete los campos requeridos: CUT, Asunto y Tipo Documento')));
      return;
    }
    setState(() => _submitting = true);
    try {
    // Capture dependencies and values before any await to avoid using BuildContext after async gaps.
    final authState = context.read<AuthCubit>().state;
    num? creadoPorId;
    num? areaActualId;
    if (authState is AuthAuthenticated) {
      creadoPorId = authState.user.id;
      areaActualId = authState.user.area?.id;
    }

    final Map<String, dynamic> dto = {
      'cut': _cut.text.trim(),
      'asunto': _asunto.text.trim(),
      'tipoDocumento': _tipoDocumento.text.trim(),
      // include created and area ids explicitly; backend allows null
      'creado_por_id': creadoPorId,
      'area_actual_id': areaActualId,
    };

    // optional: add folios only if provided
  final foliosVal = int.tryParse(_folios.text.trim());
  if (foliosVal != null) dto['folios'] = foliosVal;

    // build remitente map only including non-empty fields
    final Map<String, dynamic> remitente = {};
    if (_remitenteNombre.text.trim().isNotEmpty) remitente['nombre'] = _remitenteNombre.text.trim();
    if (_remitenteDocumento.text.trim().isNotEmpty) remitente['documento'] = _remitenteDocumento.text.trim();
    if (_remitenteDireccion.text.trim().isNotEmpty) remitente['direccion'] = _remitenteDireccion.text.trim();
    if (_remitenteEmail.text.trim().isNotEmpty) remitente['email'] = _remitenteEmail.text.trim();
    if (_remitenteTelefono.text.trim().isNotEmpty) remitente['telefono'] = _remitenteTelefono.text.trim();
    if (remitente.isNotEmpty) dto['remitente'] = remitente;

    final repo = context.read<TramiteRepository>();
    final tramiteCubit = context.read<TramiteCubit?>();

    final created = await repo.registerTramite(dto);

      num tramiteId;
      if (created is Map<String, dynamic> && created['id'] != null) {
        tramiteId = created['id'] as num;
      } else if (created is num) {
        tramiteId = created;
      } else {
        // Try to parse id inside data
        tramiteId = (created is Map && created['data'] is Map && created['data']['id'] != null) ? created['data']['id'] as num : -1;
      }

      if (tramiteId <= 0) throw Exception('No se pudo obtener el id del trámite creado');

      if (_pickedFile != null && _pickedFile!.bytes != null) {
        final bytes = _pickedFile!.bytes!;
        await repo.uploadDocumento(tramiteId, bytes, _pickedFile!.name);
      }

      // Success: refresh list if available, then navigate back.
      if (tramiteCubit != null) await tramiteCubit.fetchPage();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trámite registrado correctamente')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
