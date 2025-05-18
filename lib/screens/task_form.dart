import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/task_provider.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({super.key});

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final duration = Duration(minutes: int.parse(_durationController.text));
    final newTask = Task(
      id: const Uuid().v4(),
      title: _titleController.text,
      duration: duration,
      type: _selectedType,
      date: _date,
      startDate: _startDate,
      endDate: _endDate,
    );

    Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate(BuildContext context, Function(DateTime) onSelected) async {
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer un titre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Durée requise';
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Entrez un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<TaskType>(
                value: _selectedType,
                items: TaskType.values.map((type) {
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
                  onPressed: () => _pickDate(context, (d) => setState(() => _date = d)),
                  child: Text(_date == null
                      ? 'Choisir une date'
                      : 'Date : ${_date!.day}/${_date!.month}/${_date!.year}'),
                ),
              if (_selectedType == TaskType.semiPersistent)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickDate(context, (d) => setState(() => _startDate = d)),
                      child: Text(_startDate == null
                          ? 'Début'
                          : 'Début : ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickDate(context, (d) => setState(() => _endDate = d)),
                      child: Text(_endDate == null
                          ? 'Fin'
                          : 'Fin : ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
