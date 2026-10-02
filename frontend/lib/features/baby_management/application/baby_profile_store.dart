/// Session cache for the active baby name shared by presentation screens.
class BabyProfileStore {
  BabyProfileStore._();
  static String name = 'Your baby';
  static String? id;
  static Map<String, dynamic> data = const {};
  static List<Map<String, dynamic>> babies = const [];

  static void select(Map<String, dynamic> baby) {
    id = baby['id'] as String?;
    name = (baby['name'] as String?)?.trim().isNotEmpty == true ? (baby['name'] as String).trim() : 'Your baby';
    data = baby;
  }
}
