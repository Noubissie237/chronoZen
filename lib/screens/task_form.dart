import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/task_provider.dart';

class TaskForm extends StatefulWidget {
  final Task? existingTask;

  const TaskForm({super.key, this.existingTask});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  
  TaskType _selectedType = TaskType.nonPersistent;
  DateTime? _date;
  DateTime? _startDate;
  DateTime? _endDate;
  String _durationUnit = 'minutes';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _initializeFormData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _titleController.text = task.title;
      _durationController.text = task.duration.inMinutes.toString();
      _selectedType = task.type;
      _date = task.date;
      _startDate = task.startDate;
      _endDate = task.endDate;
      
      // Détermine l'unité appropriée
      if (task.duration.inMinutes % 60 == 0 && task.duration.inHours > 0) {
        _durationUnit = 'heures';
        _durationController.text = task.duration.inHours.toString();
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final raw = int.parse(_durationController.text);
      final duration = _durationUnit == 'heures'
          ? Duration(hours: raw)
          : Duration(minutes: raw);

      final task = Task(
        id: widget.existingTask?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        duration: duration,
        type: _selectedType,
        date: _selectedType == TaskType.nonPersistent ? (_date ?? DateTime.now()) : null,
        startDate: _selectedType == TaskType.semiPersistent ? _startDate : null,
        endDate: _selectedType == TaskType.semiPersistent ? _endDate : null,
        isDone: widget.existingTask?.isDone ?? false,
      );

      final provider = Provider.of<TaskProvider>(context, listen: false);

      if (widget.existingTask == null) {
        await provider.addTask(task);
      } else {
        await provider.updateTask(task);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingTask == null 
                ? 'Tâche créée avec succès'
                : 'Tâche mise à jour avec succès',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate(BuildContext context, Function(DateTime) onSelected) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onSelected(picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.persistent:
        return Colors.blue;
      case TaskType.semiPersistent:
        return Colors.orange;
      case TaskType.nonPersistent:
        return Colors.green;
    }
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.persistent:
        return Icons.repeat;
      case TaskType.semiPersistent:
        return Icons.schedule;
      case TaskType.nonPersistent:
        return Icons.today;
    }
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.persistent:
        return 'Persistante';
      case TaskType.semiPersistent:
        return 'Semi-persistante';
      case TaskType.nonPersistent:
        return 'Non persistante';
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: TaskType.values.map((type) {
          final isSelected = _selectedType == type;
          return InkWell(
            onTap: () => setState(() => _selectedType = type),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? _getTaskTypeColor(type).withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(12),
                border: isSelected 
                  ? Border.all(color: _getTaskTypeColor(type), width: 2)
                  : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _getTaskTypeIcon(type),
                    color: isSelected ? _getTaskTypeColor(type) : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTaskTypeLabel(type),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? _getTaskTypeColor(type) : Colors.black87,
                          ),
                        ),
                        Text(
                          _getTaskTypeDescription(type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: _getTaskTypeColor(type),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTaskTypeDescription(TaskType type) {
    switch (type) {
      case TaskType.persistent:
        return 'Se répète indéfiniment';
      case TaskType.semiPersistent:
        return 'Active pendant une période définie';
      case TaskType.nonPersistent:
        return 'À effectuer une seule fois';
    }
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required Function(DateTime) onSelected,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _pickDate(context, onSelected),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null ? _formatDate(date) : 'Sélectionner une date',
                      style: TextStyle(
                        fontSize: 16,
                        color: date != null ? Colors.black87 : Colors.grey[500],
                        fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informations de base
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Informations générales', Icons.info_outline),
                        _buildCustomFormField(
                          controller: _titleController,
                          label: 'Titre de la tâche',
                          icon: Icons.title,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Veuillez entrer un titre'
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildCustomFormField(
                                controller: _durationController,
                                label: 'Durée',
                                icon: Icons.timer,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Durée requise';
                                  }
                                  final parsed = int.tryParse(value);
                                  if (parsed == null || parsed <= 0) {
                                    return 'Nombre valide requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _durationUnit,
                                decoration: InputDecoration(
                                  labelText: 'Unité',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'minutes',
                                    child: Text('Minutes'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'heures',
                                    child: Text('Heures'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _durationUnit = value!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Type de tâche
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Type de tâche', Icons.category),
                        _buildTaskTypeSelector(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Planification
                  if (_selectedType != TaskType.persistent)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Planification', Icons.calendar_month),
                          if (_selectedType == TaskType.nonPersistent)
                            _buildDateSelector(
                              label: 'Date d\'exécution',
                              date: _date,
                              onSelected: (d) => setState(() => _date = d),
                              icon: Icons.event,
                            ),
                          if (_selectedType == TaskType.semiPersistent) ...[
                            _buildDateSelector(
                              label: 'Date de début',
                              date: _startDate,
                              onSelected: (d) => setState(() => _startDate = d),
                              icon: Icons.play_arrow,
                            ),
                            _buildDateSelector(
                              label: 'Date de fin',
                              date: _endDate,
                              onSelected: (d) => setState(() => _endDate = d),
                              icon: Icons.stop,
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Bouton de soumission
                  Container(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(isEditing ? Icons.save : Icons.add),
                                const SizedBox(width: 8),
                                Text(
                                  isEditing ? 'Mettre à jour' : 'Créer la tâche',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}