import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/area.dart';
import '../domain/repositories/admin_repository.dart';

/// Reusable dropdown form field that loads Areas from AdminRepository.
class AreaDropdownField extends StatefulWidget {
  final void Function(Area? area) onChanged;
  final num? initialValueId;
  final bool isOptional;

  const AreaDropdownField({
    super.key,
    required this.onChanged,
    this.initialValueId,
    this.isOptional = true,
  });

  @override
  State<AreaDropdownField> createState() => _AreaDropdownFieldState();
}

class _AreaDropdownFieldState extends State<AreaDropdownField> {
  late Future<List<Area>> _areasFuture;
  Area? _selected;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  void _loadAreas() {
    final repo = context.read<AdminRepository>();
    _areasFuture = repo.getAreas().catchError((e) {
      // rethrow so FutureBuilder can handle it
      throw Exception('No se pudo cargar las áreas');
    });
    // When the future completes, set initial selection if provided
    _areasFuture.then((list) {
      if (widget.initialValueId != null) {
        Area? match;
        for (final a in list) {
          if (a.id == widget.initialValueId) {
            match = a;
            break;
          }
        }
        if (match != null) {
          setState(() => _selected = match);
          widget.onChanged(match);
        }
      }
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Area>>(
      future: _areasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Error al cargar las áreas', style: TextStyle(color: Colors.red)),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _loadAreas();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          );
        }

        final areas = snapshot.data ?? [];

        final items = <DropdownMenuItem<Area?>>[];

        if (widget.isOptional) {
          items.add(DropdownMenuItem<Area?>(value: null, child: Text('Sin área')));
        }

        items.addAll(areas.map((a) => DropdownMenuItem<Area?>(value: a, child: Text(a.nombre))));

        return DropdownButtonFormField<Area?>(
          value: _selected,
          items: items,
          decoration: const InputDecoration(
            labelText: 'Área',
            border: OutlineInputBorder(),
          ),
          isExpanded: true,
          validator: (v) {
            if (!widget.isOptional && v == null) return 'Seleccione un área';
            return null;
          },
          onChanged: (val) {
            setState(() => _selected = val);
            widget.onChanged(val);
          },
        );
      },
    );
  }
}
