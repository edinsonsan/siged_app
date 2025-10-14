import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // Necesario para los formatters

import '../../domain/repositories/tramite_repository.dart';
import '../auth/auth_cubit.dart';
import 'tramite_cubit.dart';

class TramiteRegisterScreen extends StatefulWidget {
  const TramiteRegisterScreen({super.key});

  @override
  State<TramiteRegisterScreen> createState() => _TramiteRegisterScreenState();
}

class _TramiteRegisterScreenState extends State<TramiteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _cut = TextEditingController();
  final _asunto = TextEditingController();
  final _tipoDocumento = TextEditingController();
  final _folios = TextEditingController();
  final _remitenteNombre = TextEditingController();
  final _remitenteDocumento = TextEditingController();
  final _remitenteDireccion = TextEditingController();
  final _remitenteEmail = TextEditingController();
  final _remitenteTelefono = TextEditingController();

  // Estado para el tipo de remitente y el archivo adjunto
  String _selectedRemitenteTipo = 'Persona natural'; // Valor por defecto
  PlatformFile? _pickedFile;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    // Generamos el hint para el CUT dinámicamente
    final year = DateTime.now().year;
    final cutHint = 'Ej: CUT-$year-0001';

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Trámite')),
      body: Form(
        key: _formKey,
        child: ListView(
          // Usamos ListView para un mejor scroll
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Sección 1: Datos del Trámite ---
            _buildSectionCard(
              title: 'Datos del Trámite',
              icon: Icons.description,
              children: [
                TextFormField(
                  controller: _cut,
                  decoration: _inputDecoration(
                    'CUT (*)',
                    cutHint,
                    Icons.qr_code_2,
                  ),
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _asunto,
                  decoration: _inputDecoration(
                    'Asunto (*)',
                    'Ej: Solicitud de vacaciones',
                    Icons.subject,
                  ),
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tipoDocumento,
                  decoration: _inputDecoration(
                    'Tipo de Documento (*)',
                    'Ej: Oficio, Memorando',
                    Icons.article,
                  ),
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _folios,
                  decoration: _inputDecoration(
                    'N° de Folios',
                    'Ej: 5',
                    Icons.format_list_numbered,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Sección 2: Datos del Remitente ---
            _buildSectionCard(
              title: 'Datos del Remitente',
              icon: Icons.person,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRemitenteTipo,
                  decoration: _inputDecoration(
                    'Tipo de Remitente',
                    '',
                    Icons.group,
                  ),
                  items:
                      ['Persona natural', 'Empresa']
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRemitenteTipo = value;
                        _remitenteDocumento
                            .clear(); // Limpiamos el campo al cambiar
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remitenteDocumento,
                  decoration: _inputDecoration(
                    _selectedRemitenteTipo == 'Persona natural' ? 'DNI' : 'RUC',
                    _selectedRemitenteTipo == 'Persona natural'
                        ? '8 dígitos'
                        : '11 dígitos',
                    Icons.badge,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      _selectedRemitenteTipo == 'Persona natural' ? 8 : 11,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remitenteNombre,
                  decoration: _inputDecoration(
                    'Nombre Completo o Razón Social',
                    'Ej: Juan Pérez',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remitenteDireccion,
                  decoration: _inputDecoration(
                    'Dirección',
                    'Ej: Av. Principal 123',
                    Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remitenteEmail,
                  decoration: _inputDecoration(
                    'Email',
                    'ejemplo@correo.com',
                    Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remitenteTelefono,
                  decoration: _inputDecoration(
                    'Teléfono',
                    'Ej: 987654321',
                    Icons.phone_outlined,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Sección 3: Adjuntos ---
            _buildSectionCard(
              title: 'Adjuntos',
              icon: Icons.attach_file,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Adjuntar'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedFile?.name ?? 'Ningún archivo seleccionado',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Botones de Acción ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _submitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon:
                      _submitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                          : const Icon(Icons.save),
                  label: Text(_submitting ? 'Registrando...' : 'Registrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper para construir las tarjetas de sección
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper para unificar el diseño de los inputs
  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Helper para validación simple
  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete los campos obligatorios (*).'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);

    try {
      final authState = context.read<AuthCubit>().state;
      num? creadoPorId;
      num?
      areaActualId; // Por defecto, se asigna el área del usuario que registra
      if (authState is AuthAuthenticated) {
        creadoPorId = authState.user.id;
        areaActualId = authState.user.area?.id;
      }

      // --- CORRECCIÓN CRÍTICA: Construir el DTO plano ---
      final Map<String, dynamic> dto = {
        'cut': _cut.text.trim(),
        'asunto': _asunto.text.trim(),
        'tipoDocumento': _tipoDocumento.text.trim(),
        'creado_por_id': creadoPorId,
        'area_actual_id':
            areaActualId, // Mesa de partes lo deriva, así que empieza en su área.
        // Campos opcionales del trámite
        if (_folios.text.trim().isNotEmpty)
          'folios': int.tryParse(_folios.text.trim()),

        // Campos del remitente (todos opcionales, se añaden si no están vacíos)
        'remitenteTipo': _selectedRemitenteTipo,
        if (_remitenteNombre.text.trim().isNotEmpty)
          'remitenteNombre': _remitenteNombre.text.trim(),
        if (_remitenteDocumento.text.trim().isNotEmpty)
          'remitenteDniRuc': _remitenteDocumento.text.trim(),
        if (_remitenteDireccion.text.trim().isNotEmpty)
          'remitenteDireccion': _remitenteDireccion.text.trim(),
        if (_remitenteEmail.text.trim().isNotEmpty)
          'remitenteEmail': _remitenteEmail.text.trim(),
        if (_remitenteTelefono.text.trim().isNotEmpty)
          'remitenteTelefono': _remitenteTelefono.text.trim(),
      };

      final repo = context.read<TramiteRepository>();
      final created = await repo.registerTramite(dto);

      num tramiteId;
      if (created is Map<String, dynamic> && created['id'] != null) {
        tramiteId = created['id'] as num;
      } else {
        throw Exception(
          'No se pudo obtener el ID del trámite creado desde la respuesta.',
        );
      }

      if (_pickedFile != null && _pickedFile!.bytes != null) {
        await repo.uploadDocumento(
          tramiteId,
          _pickedFile!.bytes!,
          _pickedFile!.name,
          userId: creadoPorId as int?, // Asumiendo que creadoPorId es num?, lo casteamos a int?
        );
      }

      // Éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trámite registrado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      _clearFields();

      // Refrescar la bandeja de entrada antes de salir
      context.read<TramiteCubit>().fetchPage();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        // Mostramos solo el mensaje del backend
        errorMessage = errorMessage.substring('Exception: '.length);
      } else if (errorMessage.startsWith('DioException [bad response]: ')) {
        // En caso de que el manejo de errores falle por alguna razón,
        // al menos evitamos mostrar el código interno de Dio.
        errorMessage =
            'Error en la solicitud: El servidor respondió con un problema.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Método para limpiar todos los campos del formulario
  void _clearFields() {
    _cut.clear();
    _asunto.clear();
    _tipoDocumento.clear();
    _folios.clear();
    _remitenteNombre.clear();
    _remitenteDocumento.clear();
    _remitenteDireccion.clear();
    _remitenteEmail.clear();
    _remitenteTelefono.clear();
    setState(() {
      _pickedFile = null; // Limpiar el archivo adjunto
      _selectedRemitenteTipo = 'Persona natural'; // Volver al valor por defecto
    });
  }
}
