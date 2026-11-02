import 'package:flutter/material.dart';

/// Disciplines / APSA des fiches pédagogiques. Visibles dans la vidéo :
/// Documents pédagogiques, Course de vitesse, Course de demi-fond, Handball,
/// Gymnastique, ainsi que les puces arabes (القفز الطويل، رمي الجلة، كرة السلة، الكرة الطائرة…).
/// La liste complète de l'original n'est pas connue (APPROXIMATION).
class Discipline {
  final String fr;
  final String ar;
  final Color color;
  final IconData icon;
  const Discipline(this.fr, this.ar, this.color, this.icon);
}

const List<Discipline> kDisciplines = [
  Discipline('Documents pédagogiques', 'وثائق بيداغوجية', Color(0xFF3F51B5), Icons.menu_book),
  Discipline('Course de vitesse', 'سباق السرعة', Color(0xFFD32F2F), Icons.directions_run),
  Discipline('Course de demi-fond', 'سباق نصف الطويل', Color(0xFF0277BD), Icons.timer_outlined),
  Discipline('Saut en longueur', 'القفز الطويل', Color(0xFF2E7D32), Icons.moving),
  Discipline('Lancer de poids', 'رمي الجلة', Color(0xFF6D4C41), Icons.sports_baseball),
  Discipline('Gymnastique', 'الجمباز', Color(0xFF00897B), Icons.self_improvement),
  Discipline('Handball', 'كرة اليد', Color(0xFFEF6C00), Icons.sports_handball),
  Discipline('Basketball', 'كرة السلة', Color(0xFFD84315), Icons.sports_basketball),
  Discipline('Volleyball', 'الكرة الطائرة', Color(0xFF7B1FA2), Icons.sports_volleyball),
];

Discipline? disciplineByFr(String? fr) {
  for (final d in kDisciplines) {
    if (d.fr == fr) return d;
  }
  return null;
}
