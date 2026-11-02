import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/levels.dart';
import '../models/models.dart';
import '../providers/classes_provider.dart';
import '../providers/core_providers.dart';
import '../themes/app_colors.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/class_form_sheet.dart';
import 'attendance_screen.dart';
import 'class_detail_screen.dart';
import 'global_student_search_screen.dart';

/// Onglet « الأقسام » : filtres par niveau, cartes de classe, création.
class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});
  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen> {
  String? _levelFilter; // null = tous

  Future<void> _confirmDelete(SchoolClass c) async {
    final tr = ref.read(trProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('delete_class_q')),
        content: Text(tr('delete_class_msg')),
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
      await ref.read(classesProvider.notifier).remove(c.id!);
      if (mounted) showSuccessSnack(context, tr('class_deleted'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(trProvider);
    final classesAsync = ref.watch(classesProvider);
    final all = classesAsync.valueOrNull ?? const <SchoolClass>[];
    final levelsPresent = <String>[];
    for (final c in all) {
      if (!levelsPresent.contains(c.level)) levelsPresent.add(c.level);
    }
    final shown = _levelFilter == null
        ? all
        : all.where((c) => c.level == _levelFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('classes_title')),
        // Icônes de la barre (recherche / sac médical) : rôles déduits des icônes de la vidéo.
        actions: [
          IconButton(
            tooltip: tr('ex_students_title'),
            icon: const Icon(Icons.medical_services_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GlobalStudentSearchScreen(onlyExempt: true))),
          ),
          IconButton(
            tooltip: tr('gs_title'),
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GlobalStudentSearchScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showClassFormSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.group_add),
        label: Text(tr('new_class')),
      ),
      body: Column(
        children: [
          Container(
            height: 52,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(
                  label: tr('all_classes'),
                  selected: _levelFilter == null,
                  onTap: () => setState(() => _levelFilter = null),
                ),
                for (final l in levelsPresent)
                  _FilterChip(
                    label: kLevels[l]?.ar ?? l,
                    selected: _levelFilter == l,
                    onTap: () => setState(() => _levelFilter = l),
                  ),
              ],
            ),
          ),
          Expanded(
            child: classesAsync.isLoading && all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : shown.isEmpty
                    ? _EmptyState(
                        text: tr('no_classes_level'),
                        buttonLabel: tr('create_class'),
                        onPressed: () => showClassFormSheet(context, ref),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 90),
                        itemCount: shown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ClassCard(
                          c: shown[i],
                          onOpen: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ClassDetailScreen(schoolClass: shown[i]))),
                          onEdit: () => showClassFormSheet(context, ref, existing: shown[i]),
                          onDelete: () => _confirmDelete(shown[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : const Color(0xFFE3EAF3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppColors.primary,
              )),
        ),
      ),
    );
  }
}

class _ClassCard extends ConsumerWidget {
  final SchoolClass c;
  final VoidCallback onOpen, onEdit, onDelete;
  const _ClassCard({required this.c, required this.onOpen, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(trProvider);
    final stripe = colorFromHex(c.colorCode);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: stripe),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(tr('edit'))),
                            PopupMenuItem(value: 'delete', child: Text(tr('delete'))),
                          ],
                        ),
                        Expanded(
                          child: Text(c.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: stripe.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(c.level,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: stripe)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: onOpen,
                          child: Row(children: [
                            Text(tr('manage_students'),
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            const Icon(Icons.chevron_left, size: 16, color: AppColors.primary),
                          ]),
                        ),
                        const Spacer(),
                        Icon(Icons.groups_2_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text('${c.studentCount} ${tr('students_count')}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AttendanceScreen(schoolClass: c))),
                      icon: const Icon(Icons.how_to_reg, size: 18),
                      label: Text(tr('call_roll')),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.present,
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text, buttonLabel;
  final VoidCallback onPressed;
  const _EmptyState({required this.text, required this.buttonLabel, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
