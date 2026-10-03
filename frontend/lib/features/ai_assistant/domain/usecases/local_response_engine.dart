import '../../../baby_management/application/baby_profile_store.dart';

class LocalResponseEngine {
  const LocalResponseEngine();
  String respond(String question) {
    final name = BabyProfileStore.name;
    final data = BabyProfileStore.data;
    final q = question.toLowerCase();
    String recorded(String key, String unit) =>
        data[key] == null ? 'not recorded' : '${data[key]}$unit';
    if (q.contains('weight') ||
        q.contains('height') ||
        q.contains('growth') ||
        q.contains('head')) {
      return "$name's registration measurements: weight ${recorded('birth_weight_kg', ' kg')}, height ${recorded('birth_length_cm', ' cm')}, head circumference ${recorded('head_circumference_cm', ' cm')}. No growth trend is available.";
    }
    if (q.contains('blood'))
      return "$name's blood group: ${recorded('blood_group', '')}.";
    if (q.contains('allerg'))
      return "$name's allergy notes: ${recorded('allergies', '')}.";
    if (q.contains('doctor') ||
        q.contains('pediatrician') ||
        q.contains('hospital'))
      return "$name's pediatrician: ${recorded('pediatrician', '')}. Hospital: ${recorded('hospital', '')}.";
    if (q.contains('birth') || q.contains('gender') || q.contains('profile'))
      return "$name's birth date: ${recorded('birth_date', '')}. Gender: ${recorded('gender', '')}.";
    return "I'm viewing $name's profile. I don't have saved sleep, feeding, diaper, vaccine, milestone, or cry-analysis records available here yet. You can ask about the recorded profile details.";
  }
}
