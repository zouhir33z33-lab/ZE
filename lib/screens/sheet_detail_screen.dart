import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../constants/disciplines.dart';
import '../models/models.dart';
import '../providers/core_providers.dart';
import '../providers/repository_providers.dart';
import '../themes/app_colors.dart';
import '../widgets/app_bottom_sheet.dart';
import 'sheet_form_screen.dart';

/// Consultation d'une fiche : texte, aperçu PDF ou image.
class SheetDetailScreen extends ConsumerWidget {
  final PedagogicalSheet sheet;
  const SheetDetailScreen({super.key, required this.sheet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(trProvider);
    final d = disciplineByFr(sheet.sportDiscipline);
    final path = sheet.filePath;
    final fileOk = path != null && File(path).existsSync();

    Widget body;
    if (sheet.fileType == 'PDF' && fileOk) {
      body = Column(
        children: [
          if ((sheet.textContent ?? '').isNotEmpty)
            Padding(padding: const EdgeInsets.all(12), child: SelectableText(sheet.textContent!)),
          Expanded(
            child: PdfPreview(
              build: (_) => File(path).readAsBytes(),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
            ),
          ),
        ],
      );
    } else if (sheet.fileType == 'IMAGE' && fileOk) {
      body = Column(
        children: [
          Expanded(child: InteractiveViewer(child: Center(child: Image.file(File(path))))),
          if ((sheet.textContent ?? '').isNotEmpty)
            Padding(padding: const EdgeInsets.all(12), child: SelectableText(sheet.textContent!)),
        ],
      );
    } else if (sheet.fileType == 'TEXT') {
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(sheet.textContent ?? '', style: const TextStyle(fontSize: 15, height: 1.6)),
      );
    } else {
      body = Center(child: Text(tr('sh_file_missing')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sheet.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (d != null)
              Text(d.fr, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SheetFormScreen(existing: sheet)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(tr('sh_delete_q')),
                  content: Text(tr('sh_delete_msg')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('cancel'))),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(tr('delete'), style: const TextStyle(color: AppColors.absent)),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(sheetRepositoryProvider).delete(sheet);
                if (context.mounted) {
                  Navigator.pop(context);
                  showSuccessSnack(context, tr('sh_deleted'));
                }
              }
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
