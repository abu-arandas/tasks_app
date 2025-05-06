import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tag_controller.dart';
import '../../models/tag.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  final TagController _tagController = Get.find<TagController>();
  final TextEditingController _tagNameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  // List of available colors for tag creation
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void dispose() {
    _tagNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
      ),
      body: Column(
        children: [
          // Add tag section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create New Tag',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tagNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tag Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Color:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_tagNameController.text.trim().isNotEmpty) {
                            _tagController.addTag(
                              _tagNameController.text.trim(),
                              '#${_selectedColor.value.toRadixString(16).substring(2)}',
                            );
                            _tagNameController.clear();
                            setState(() {
                              _selectedColor = Colors.blue;
                            });
                          }
                        },
                        child: const Text('Add Tag'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tag list
          Expanded(
            child: Obx(() {
              return _tagController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _tagController.tags.isEmpty
                      ? const Center(child: Text('No tags created yet'))
                      : ListView.builder(
                          itemCount: _tagController.tags.length,
                          itemBuilder: (context, index) {
                            final tag = _tagController.tags[index];
                            return Dismissible(
                              key: Key(tag.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _tagController.deleteTag(tag.id);
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(int.parse('0xFF${tag.color.substring(1)}', radix: 16)),
                                ),
                                title: Text(tag.name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditTagDialog(context, tag);
                                  },
                                ),
                              ),
                            );
                          },
                        );
            }),
          ),
        ],
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag) {
    final TextEditingController editController = TextEditingController(text: tag.name);
    Color selectedEditColor = Color(int.parse('0xFF${tag.color.substring(1)}', radix: 16));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tag'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Color:'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedEditColor = color;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedEditColor == color ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                _tagController.updateTag(tag);
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
