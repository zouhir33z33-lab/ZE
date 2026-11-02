import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/academic_providers.dart';
import '../providers/core_providers.dart';
import '../providers/students_provider.dart';
import '../themes/app_colors.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/student_form_sheet.dart';
import 'attendance_screen.dart';
import 'evaluations_screen.dart';

/// Détail d'une classe : trimestres, recherche, liste des élèves (CRUD).
class ClassDetailScreen extends ConsumerStatefulWidget {
  final SchoolClass schoolClass;
  const ClassDetailScreen({super.key, required this.schoolClass});
  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> {
  final _search = TextEditingController();
  bool _onlyExempt = false;
  bool _byNumber = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Student s) async {
    final tr = ref.read(trProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('delete_student_q')),
        content: Text(tr('delete_student_msg')),
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
      await ref.read(studentsProvider(widget.schoolClass.id!).notifier).remove(s.id!);
      if (mounted) showSuccessSnack(context, tr('student_deleted'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.schoolClass;
    final tr = ref.watch(trProvider);
    final studentsAsync = ref.watch(studentsProvider(c.id!));
    final all = studentsAsync.valueOrNull ?? const <Student>[];
    final exemptCount = all.where((s) => s.isExempt).length;
    final q = _search.text.trim().toLowerCase();
    var shown = all.where((s) {
      if (_onlyExempt && !s.isExempt) return false;
      if (q.isEmpty) return true;
      return s.fullName.toLowerCase().contains(q) ||
          (s.studentNumber ?? '').toLowerCase().contains(q);
    }).toList();
    if (_byNumber) {
      shown.sort((a, b) => (a.studentNumber ?? '').compareTo(b.studentNumber ?? ''));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${c.level} • ${tr('student_manage')}',
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showStudentFormSheet(context, ref, schoolClass: c),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(tr('add_student')),
      ),
      body: Column(
        children: [
          const _TermChips(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AttendanceScreen(schoolClass: c))),
                    icon: const Icon(Icons.how_to_reg, size: 18),
                    label: Text(tr('btn_attendance')),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EvaluationsScreen(schoolClass: c))),
                    icon: const Icon(Icons.flag, size: 18),
                    label: Text(tr('btn_grades')),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: tr('search_student'),
                      isDense: true,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _byNumber = !_byNumber),
                  icon: const Icon(Icons.sort, size: 18),
                  label: Text(tr('sort')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('${tr('filter_all')} (${all.length})'),
                  selected: !_onlyExempt,
                  onSelected: (_) => setState(() => _onlyExempt = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('${tr('filter_exempt')} ($exemptCount)'),
                  selected: _onlyExempt,
                  onSelected: (_) => setState(() => _onlyExempt = true),
                ),
              ],
            ),
          ),
          Expanded(
            child: studentsAsync.isLoading && all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : shown.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off_outlined, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(tr('no_students'), style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                        itemCount: shown.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = shown[i];
                          final girl = s.gender == 'F';
                          final tint = girl ? const Color(0xFFD81B60) : AppColors.primary;
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: CircleAvatar(
                                backgroundColor: tint.withOpacity(0.12),
                                child: Text(girl ? 'F' : 'G',
                                    style: TextStyle(color: tint, fontWeight: FontWeight.bold)),
                              ),
                              title: Row(children: [
                                Flexible(child: Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                if (s.hasPai || s.isExempt) ...[
                                  const SizedBox(width: 6),
                                  Icon(s.isExempt ? Icons.medical_services : Icons.health_and_safety,
                                      size: 16, color: s.isExempt ? const Color(0xFF00838F) : AppColors.absent),
                                ],
                              ]),
                              subtitle: (s.studentNumber ?? '').isEmpty ? null : Text(s.studentNumber!),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                                    onPressed: () => showStudentFormSheet(context, ref,
                                        schoolClass: c, existing: s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 22, color: AppColors.absent),
                                    onPressed: () => _confirmDelete(s),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Puces de trimestre. La sélection sera utilisée par l'appel et les notes
/// (étapes suivantes) ; le verrouillage vient du champ terms.is_locked.
class _TermChips extends ConsumerWidget {
  const _TermChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terms = ref.watch(termsProvider).valueOrNull ?? const <Term>[];
    final selected = ref.watch(selectedTermIdProvider) ??
        terms.where((t) => t.isCurrent).map((t) => t.id).firstOrNull;
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final t in terms)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                avatar: Icon(
                  t.isLocked ? Icons.lock : (t.isCurrent ? Icons.star : null),
                  size: 14,
                ),
                label: Text(t.name),
                selected: selected == t.id,
                onSelected: (_) => ref.read(selectedTermIdProvider.notifier).state = t.id,
              ),
            ),
        ],
      ),
    );
  }
}
