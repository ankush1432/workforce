import 'package:supervisor_app/features/employees/domain/employee_model.dart';
import 'package:supervisor_app/features/employees/domain/face_registration_status.dart';

class FaceRegistrationResult {
  const FaceRegistrationResult({
    required this.registrationStatus,
    required this.embeddingExists,
    required this.faceRegistered,
    this.employee,
    this.confidence,
  });

  final FaceRegistrationStatus registrationStatus;
  final bool embeddingExists;
  final bool faceRegistered;
  final EmployeeModel? employee;
  final double? confidence;

  factory FaceRegistrationResult.fromJson(Map<String, dynamic> json) {
    final employeeJson = json['employee'];
    return FaceRegistrationResult(
      registrationStatus:
          FaceRegistrationStatus.fromApi(json['registration_status'] as String?),
      embeddingExists: json['embedding_exists'] as bool? ?? false,
      faceRegistered: json['face_registered'] as bool? ?? false,
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : double.tryParse(json['confidence']?.toString() ?? '0'),
      employee: employeeJson != null
          ? EmployeeModel.fromJson(Map<String, dynamic>.from(employeeJson))
          : null,
    );
  }
}
