import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/services/logger_service.dart';

class DeveloperModePage extends StatefulWidget {
  const DeveloperModePage({super.key});

  @override
  State<DeveloperModePage> createState() => _DeveloperModePageState();
}

class _DeveloperModePageState extends State<DeveloperModePage> {
  String _logs = 'Cargando logs...';
  final _logger = GetIt.I<ILoggerService>();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _logger.getLogs();
    setState(() {
      _logs = logs;
    });
  }

  Future<void> _clearLogs() async {
    await _logger.clearLogs();
    _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Mode - Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearLogs,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _logs,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
