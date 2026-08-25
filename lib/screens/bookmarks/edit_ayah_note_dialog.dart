import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../models/ayah.dart';
import '../../providers/notes_provider.dart';

class EditAyahNoteDialog extends StatefulWidget {
  final Ayah ayah;
  final String? initialNote;

  const EditAyahNoteDialog({
    super.key,
    required this.ayah,
    this.initialNote,
  });

  static Future<void> show(BuildContext context, Ayah ayah, {String? initialNote}) {
    return showDialog(
      context: context,
      builder: (context) => EditAyahNoteDialog(ayah: ayah, initialNote: initialNote),
    );
  }

  @override
  State<EditAyahNoteDialog> createState() => _EditAyahNoteDialogState();
}

class _EditAyahNoteDialogState extends State<EditAyahNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
    if (widget.initialNote == null) {
      _loadExistingNote();
    }
  }

  void _loadExistingNote() async {
    final sNum = widget.ayah.surahNumber ?? 1;
    final aNum = widget.ayah.numberInSurah;
    final note = await context.read<NotesProvider>().getNoteForAyah(sNum, aNum);
    if (note != null && mounted) {
      setState(() {
        _controller.text = note.noteText;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sName = widget.ayah.surahEnglishName ?? 'Surah';
    final aNum = widget.ayah.numberInSurah;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: AppConstants.primaryGreen, size: 28),
          const SizedBox(width: 8),
          Text(
            'Note: $sName ($aNum)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.gold.withOpacity(0.3)),
            ),
            child: Text(
              widget.ayah.text,
              style: const TextStyle(
                fontFamily: AppConstants.uthmaniFont,
                fontSize: 16,
                color: AppConstants.primaryGreen,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Write your reflection or personal note on this verse...',
              hintStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
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
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              await context.read<NotesProvider>().saveNote(
                surahNumber: widget.ayah.surahNumber ?? 1,
                ayahNumber: widget.ayah.numberInSurah,
                surahName: widget.ayah.surahName ?? 'سورة',
                surahEnglishName: widget.ayah.surahEnglishName ?? 'Surah',
                noteText: text,
              );
            }
            if (mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Note'),
        ),
      ],
    );
  }
}
