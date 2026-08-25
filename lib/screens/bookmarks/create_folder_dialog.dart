import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../models/bookmark_folder_model.dart';
import '../../providers/bookmark_provider.dart';

class CreateFolderDialog extends StatefulWidget {
  final BookmarkFolder? existingFolder;
  const CreateFolderDialog({super.key, this.existingFolder});

  static Future<void> show(BuildContext context, {BookmarkFolder? existingFolder}) {
    return showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(existingFolder: existingFolder),
    );
  }

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  late final TextEditingController _nameController;
  int _selectedColor = 0xFF0D4D4D;

  static const List<int> _folderColors = [
    0xFF0D4D4D, // Primary Green
    0xFFC9A227, // Gold
    0xFF42A5F5, // Soft Blue
    0xFF9575CD, // Soft Purple
    0xFFF06292, // Soft Pink
    0xFFFF8A65, // Soft Orange
    0xFF4DB6AC, // Soft Teal
    0xFFE0534E, // Danger Red
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingFolder?.name ?? '');
    _selectedColor = widget.existingFolder?.colorValue ?? _folderColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingFolder != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(isEditing ? 'Edit Category' : 'New Bookmark Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Daily Recitation, Duas, Hifz',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Color Badge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _folderColors.map((colVal) {
              final isSelected = colVal == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = colVal),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(colVal),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              final provider = context.read<BookmarkProvider>();
              if (isEditing) {
                await provider.updateFolder(
                  widget.existingFolder!.copyWith(name: name, colorValue: _selectedColor),
                );
              } else {
                await provider.createFolder(name, _selectedColor);
              }
              if (mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
