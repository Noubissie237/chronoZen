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

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  TaskType _selectedType = TaskType.nonPersistent;
  DateTime? _date;
  DateTime? _startDate;
  DateTime? _endDate;
  String _durationUnit = 'minutes'; // ou 'heures'

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _titleController.text = task.title;
      _durationController.text = task.duration.inMinutes.toString();
      _selectedType = task.type;
      _date = task.date;
      _startDate = task.startDate;
      _endDate = task.endDate;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final isNonPersistent = _selectedType == TaskType.nonPersistent;
    final raw = int.parse(_durationController.text);
    final duration =
        _durationUnit == 'heures'
            ? Duration(hours: raw)
            : Duration(minutes: raw);

    final task = Task(
      id: widget.existingTask?.id ?? const Uuid().v4(),
      title: _titleController.text,
      duration: duration,
      type: _selectedType,
      date: isNonPersistent ? _date ?? DateTime.now() : null,
      startDate: _startDate,
      endDate: _endDate,
      isDone: widget.existingTask?.isDone ?? false,
    );

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.existingTask == null) {
      await provider.addTask(task);
    } else {
      await provider.updateTask(task);
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickDate(
    BuildContext context,
    Function(DateTime) onSelected,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Veuillez entrer un titre'
                            : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _durationUnit,
                items: const [
                  DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                  DropdownMenuItem(value: 'heures', child: Text('Heures')),
                ],
                onChanged: (value) => setState(() => _durationUnit = value!),
                decoration: const InputDecoration(labelText: 'Unité de durée'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Durée'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Durée requise';
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0)
                    return 'Entrez un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<TaskType>(
                value: _selectedType,
                items:
                    TaskType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
                decoration: const InputDecoration(labelText: 'Type de tâche'),
              ),
              const SizedBox(height: 12),
              if (_selectedType == TaskType.nonPersistent)
                ElevatedButton(
                  onPressed:
                      () =>
                          _pickDate(context, (d) => setState(() => _date = d)),
                  child: Text(
                    _date == null
                        ? 'Choisir une date'
                        : 'Date : ${_date!.day}/${_date!.month}/${_date!.year}',
                  ),
                ),
              if (_selectedType == TaskType.semiPersistent)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          () => _pickDate(
                            context,
                            (d) => setState(() => _startDate = d),
                          ),
                      child: Text(
                        _startDate == null
                            ? 'Début'
                            : 'Début : ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => _pickDate(
                            context,
                            (d) => setState(() => _endDate = d),
                          ),
                      child: Text(
                        _endDate == null
                            ? 'Fin'
                            : 'Fin : ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  widget.existingTask == null ? 'Ajouter' : 'Mettre à jour',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
