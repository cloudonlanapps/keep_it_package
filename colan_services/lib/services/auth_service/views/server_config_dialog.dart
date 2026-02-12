import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';

/// Dialog for editing server configuration URLs.
class ServerConfigDialog extends ConsumerStatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  ConsumerState<ServerConfigDialog> createState() =>
      _ServerConfigDialogState();
}

class _ServerConfigDialogState extends ConsumerState<ServerConfigDialog> {
  late TextEditingController _authUrlController;
  late TextEditingController _computeUrlController;
  late TextEditingController _storeUrlController;
  late TextEditingController _mqttUrlController;

  @override
  void initState() {
    super.initState();

    final serverPrefs = ref.read(serverPreferencesProvider);
    _authUrlController = TextEditingController(text: serverPrefs.authUrl);
    _computeUrlController = TextEditingController(text: serverPrefs.computeUrl);
    _storeUrlController = TextEditingController(text: serverPrefs.storeUrl);
    _mqttUrlController = TextEditingController(text: serverPrefs.mqttUrl);
  }

  @override
  void dispose() {
    _authUrlController.dispose();
    _computeUrlController.dispose();
    _storeUrlController.dispose();
    _mqttUrlController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(serverPreferencesProvider.notifier).updateUrls(
          authUrl: _authUrlController.text.trim(),
          computeUrl: _computeUrlController.text.trim(),
          storeUrl: _storeUrlController.text.trim(),
          mqttUrl: _mqttUrlController.text.trim(),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Server Configuration'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Configure server URLs for authentication and services.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _authUrlController,
                label: 'Auth Server URL',
                hint: 'http://localhost:8010',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _computeUrlController,
                label: 'Compute Server URL',
                hint: 'http://localhost:8012',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _storeUrlController,
                label: 'Store Server URL',
                hint: 'http://localhost:8011',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _mqttUrlController,
                label: 'MQTT Broker URL',
                hint: 'mqtt://localhost:1883',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
