/// Statuts de présence par défaut.
/// Libellés arabes et ordre : relevés dans la vidéo (liste « أخرى »).
/// ATTENTION : les codes techniques, libellés FR/EN et couleurs exactes sont
/// des APPROXIMATIONS (non extractibles du binaire) – à valider avec la vidéo.
class DefaultStatus {
  final String code, labelFr, labelAr, labelEn, colorHex, icon;
  final bool countsAsAbsence;
  const DefaultStatus(this.code, this.labelFr, this.labelAr, this.labelEn,
      this.colorHex, this.icon, this.countsAsAbsence);
}

const List<DefaultStatus> kDefaultStatuses = [
  DefaultStatus('PRESENT', 'Présent', 'حاضر', 'Present', '#2E7D32', 'check', false),
  DefaultStatus('ABSENT', 'Absent', 'غائب', 'Absent', '#C62828', 'close', true),
  DefaultStatus('LATE', 'Retard', 'تأخر', 'Late', '#EF6C00', 'schedule', false),
  DefaultStatus('NO_KIT', 'Sans tenue', 'بدون بدلة', 'No kit', '#6A1B9A', 'checkroom', false),
  DefaultStatus('SICK', 'Malade', 'مريض', 'Sick', '#4E342E', 'sick', false),
  DefaultStatus('EXPELLED', 'Exclu', 'طرد', 'Expelled', '#880E4F', 'block', false),
  DefaultStatus('RUNAWAY', 'Fugue', 'هروب', 'Runaway', '#D84315', 'directions_run', true),
  DefaultStatus('EXEMPT', 'Dispensé', 'معفى', 'Exempt', '#0277BD', 'medical', false),
  DefaultStatus('EMERGENCY', 'Urgence', 'طارئ', 'Emergency', '#37474F', 'warning', false),
];
