import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../plugins/plugin_interface.dart';
import '../../services/plugin_manager.dart';

class PluginSettingsScreen extends StatelessWidget {
  final PluginManager _pluginManager = Get.find<PluginManager>();

  PluginSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('plugins'.tr),
      ),
      body: Obx(() {
        if (_pluginManager.plugins.isEmpty) {
          return Center(
            child: Text('no_plugins'.tr),
          );
        }

        return ListView.builder(
          itemCount: _pluginManager.plugins.length,
          itemBuilder: (context, index) {
            final plugin = _pluginManager.plugins[index];
            return _buildPluginCard(context, plugin);
          },
        );
      }),
    );
  }

  Widget _buildPluginCard(BuildContext context, PluginInterface plugin) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(plugin.icon),
            title: Text(plugin.name),
            subtitle: Text(plugin.description),
            trailing: Obx(() {
              final isEnabled = _pluginManager.enabledPlugins.any((p) => p.id == plugin.id);
              return Switch(
                value: isEnabled,
                onChanged: (value) async {
                  if (value) {
                    await _pluginManager.enablePlugin(plugin.id);
                  } else {
                    await _pluginManager.disablePlugin(plugin.id);
                  }
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Version: ${plugin.version}'),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                _showPluginSettings(context, plugin);
              },
              child: Text('plugin_settings'.tr),
            ),
          ),
        ],
      ),
    );
  }

  void _showPluginSettings(BuildContext context, PluginInterface plugin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                AppBar(
                  title: Text('${plugin.name} Settings'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: plugin.buildSettingsWidget(context),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
