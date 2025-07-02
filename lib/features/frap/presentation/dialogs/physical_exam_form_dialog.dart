import 'package:bg_med/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PhysicalExamFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PhysicalExamFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<PhysicalExamFormDialog> createState() => _PhysicalExamFormDialogState();
}

class _PhysicalExamFormDialogState extends State<PhysicalExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Lista de signos vitales
  final List<String> _vitalSigns = [
    'T/A',
    'FC',
    'FR',
    'Temp.',
    'Sat. O2',
    'LLC',
    'Glu',
    'Glasgow',
  ];

  // Lista de horas/columnas dinámicas
  List<String> _timeColumns = ['Hora 1', 'Hora 2', 'Hora 3'];
  
  // Mapa para almacenar los valores de cada signo vital por hora
  Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeForm();
  }

  void _initializeControllers() {
    for (String vitalSign in _vitalSigns) {
      _controllers[vitalSign] = {};
      for (String timeColumn in _timeColumns) {
        _controllers[vitalSign]![timeColumn] = TextEditingController();
      }
    }
  }

  void _initializeForm() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      
      // Cargar columnas de tiempo si existen
      if (data['timeColumns'] != null) {
        _timeColumns = List<String>.from(data['timeColumns']);
        _initializeControllers(); // Re-inicializar controladores con las nuevas columnas
      }
      
      // Cargar valores de los signos vitales
      for (String vitalSign in _vitalSigns) {
        if (data[vitalSign] != null) {
          Map<String, dynamic> vitalData = data[vitalSign];
          for (String timeColumn in _timeColumns) {
            if (vitalData[timeColumn] != null) {
              _controllers[vitalSign]![timeColumn]?.text = vitalData[timeColumn];
            }
          }
        }
      }
    }
  }

  void _addTimeColumn() {
    setState(() {
      int newColumnNumber = _timeColumns.length + 1;
      String newColumn = 'Hora $newColumnNumber';
      _timeColumns.add(newColumn);
      
      // Agregar controladores para la nueva columna
      for (String vitalSign in _vitalSigns) {
        _controllers[vitalSign]![newColumn] = TextEditingController();
      }
    });
  }

  void _removeTimeColumn(String columnToRemove) {
    if (_timeColumns.length > 1) {
      setState(() {
        _timeColumns.remove(columnToRemove);
        
        // Remover controladores de la columna eliminada
        for (String vitalSign in _vitalSigns) {
          _controllers[vitalSign]![columnToRemove]?.dispose();
          _controllers[vitalSign]!.remove(columnToRemove);
        }
        
        // Renumerar las columnas para mantener la secuencia correcta
        _renumberTimeColumns();
      });
    }
  }

  void _renumberTimeColumns() {
    // Crear nueva lista con numeración correcta
    List<String> newTimeColumns = [];
    for (int i = 0; i < _timeColumns.length; i++) {
      newTimeColumns.add('Hora ${i + 1}');
    }
    
    // Si los nombres han cambiado, actualizar controladores
    if (!_areListsEqual(_timeColumns, newTimeColumns)) {
      Map<String, Map<String, TextEditingController>> newControllers = {};
      
      for (String vitalSign in _vitalSigns) {
        newControllers[vitalSign] = {};
        for (int i = 0; i < _timeColumns.length; i++) {
          String oldColumn = _timeColumns[i];
          String newColumn = newTimeColumns[i];
          
          // Transferir el controlador existente al nuevo nombre
          newControllers[vitalSign]![newColumn] = _controllers[vitalSign]![oldColumn]!;
        }
      }
      
      _controllers = newControllers;
      _timeColumns = newTimeColumns;
    }
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    // Dispose todos los controladores
    for (String vitalSign in _vitalSigns) {
      for (String timeColumn in _timeColumns) {
        _controllers[vitalSign]![timeColumn]?.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'EXPLORACIÓN FÍSICA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Controls bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Mediciones por hora:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _addTimeColumn,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar Hora'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: _buildVitalSignsTable(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveForm,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Guardando...' : 'Guardar Sección'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignsTable() {
    const double columnWidth = 120.0;
    const double labelWidth = 80.0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Empty cell for vital signs labels
                Container(
                  width: labelWidth,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Text(
                    'Signos\nVitales',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Time column headers
                ..._timeColumns.map((timeColumn) => _buildTimeColumnHeader(timeColumn, columnWidth)),
              ],
            ),
          ),
          
          // Data rows
          ..._vitalSigns.asMap().entries.map((entry) {
            int index = entry.key;
            String vitalSign = entry.value;
            return _buildVitalSignRow(vitalSign, index, labelWidth, columnWidth);
          }),
        ],
      ),
    );
  }

  Widget _buildTimeColumnHeader(String timeColumn, double width) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              timeColumn,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          if (_timeColumns.length > 1)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeTimeColumn(timeColumn),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalSignRow(String vitalSign, int index, double labelWidth, double columnWidth) {
    final isEvenRow = index % 2 == 0;
    final backgroundColor = isEvenRow ? Colors.white : Colors.grey[50];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Vital sign label
          Container(
            width: labelWidth,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              vitalSign,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          
          // Input fields for each time column
          ..._timeColumns.map((timeColumn) => _buildInputCell(vitalSign, timeColumn, columnWidth)),
        ],
      ),
    );
  }

  Widget _buildInputCell(String vitalSign, String timeColumn, double width) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        controller: _controllers[vitalSign]![timeColumn],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          isDense: true,
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formData = <String, dynamic>{
        'timeColumns': _timeColumns,
      };

      // Guardar datos de signos vitales
      for (String vitalSign in _vitalSigns) {
        Map<String, String> vitalData = {};
        for (String timeColumn in _timeColumns) {
          String value = _controllers[vitalSign]![timeColumn]?.text.trim() ?? '';
          if (value.isNotEmpty) {
            vitalData[timeColumn] = value;
          }
        }
        if (vitalData.isNotEmpty) {
          formData[vitalSign] = vitalData;
        }
      }

      widget.onSave(formData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Exploración física guardada'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Error al guardar: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 