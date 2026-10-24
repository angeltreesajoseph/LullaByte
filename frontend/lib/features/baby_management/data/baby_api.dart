import 'package:dio/dio.dart';
import '../../../core/network/care_dio.dart';

class BabyApi {
  const BabyApi(this._dio);
  final Dio _dio;
  Future<void> create({
    required String name,
    String? photoData,
    DateTime? birthDate,
    String? gender,
    double? birthWeightKg,
    double? birthLengthCm,
    String? bloodGroup,
    String? allergies,
    String? pediatrician,
    String? hospital,
    String? parentPhone,
    String? pediatricianPhone,
    double? headCircumferenceCm,
  }) async {
    CareRevisions.invalidateSnapshots();
    await _dio.post(
      '/babies',
      data: {
        'name': name.trim(),
        'photo_data': photoData,
        ...?birthDate == null
            ? null
            : {'birth_date': birthDate.toIso8601String().split('T').first},
        ...?gender == null ? null : {'gender': gender},
        ...?birthWeightKg == null ? null : {'birth_weight_kg': birthWeightKg},
        ...?birthLengthCm == null ? null : {'birth_length_cm': birthLengthCm},
        ...?bloodGroup == null ? null : {'blood_group': bloodGroup},
        ...?allergies == null ? null : {'allergies': allergies},
        ...?pediatrician == null ? null : {'pediatrician': pediatrician},
        ...?hospital == null ? null : {'hospital': hospital},
        ...?parentPhone == null ? null : {'parent_phone': parentPhone.trim()},
        ...?pediatricianPhone == null
            ? null
            : {'pediatrician_phone': pediatricianPhone.trim()},
        ...?headCircumferenceCm == null
            ? null
            : {'head_circumference_cm': headCircumferenceCm},
      },
    );
    CareRevisions.invalidateSnapshots();
  }

  Future<List<Map<String, dynamic>>> list({bool fresh = false}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/babies',
      options: fresh ? Options(extra: {'fresh': true}) : null,
    );
    final payload = response.data?['data'];
    if (payload is! List) return const [];
    return payload.whereType<Map<String, dynamic>>().toList();
  }
}
