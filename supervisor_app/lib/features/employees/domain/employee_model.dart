import 'package:supervisor_app/features/employees/domain/face_registration_status.dart';

class EmployeeModel {
  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.faceRegistered,
    this.department,
    this.fullName,
    FaceRegistrationStatus? faceStatus,
    this.embeddingExists = false,
  }) : faceStatus = faceStatus ?? _statusFromLegacy(jsonFaceRegistered: faceRegistered);

  final int id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String? fullName;
  final String? department;
  final bool faceRegistered;
  final FaceRegistrationStatus faceStatus;
  final bool embeddingExists;

  String get displayName => fullName ?? '$firstName $lastName';

  bool get canVerifyFace =>
      faceStatus == FaceRegistrationStatus.registered && embeddingExists;

  bool get needsFaceRegistration => faceStatus.needsRegistration || !embeddingExists;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final registered = json['face_registered'] as bool? ?? false;
    final status = FaceRegistrationStatus.fromApi(json['face_registration_status'] as String?);

    return EmployeeModel(
      id: json['id'] as int,
      employeeCode: json['employee_code'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String?,
      department: json['department'] as String?,
      faceRegistered: registered,
      faceStatus: registered && status == FaceRegistrationStatus.notRegistered
          ? FaceRegistrationStatus.registered
          : status,
      embeddingExists: json['embedding_exists'] as bool? ?? registered,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_code': employeeCode,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': displayName,
        'department': department,
        'face_registered': faceRegistered,
        'face_registration_status': faceStatus.apiValue,
        'embedding_exists': embeddingExists,
      };

  EmployeeModel copyWith({
    bool? faceRegistered,
    FaceRegistrationStatus? faceStatus,
    bool? embeddingExists,
  }) =>
      EmployeeModel(
        id: id,
        employeeCode: employeeCode,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        department: department,
        faceRegistered: faceRegistered ?? this.faceRegistered,
        faceStatus: faceStatus ?? this.faceStatus,
        embeddingExists: embeddingExists ?? this.embeddingExists,
      );

  static FaceRegistrationStatus _statusFromLegacy({required bool jsonFaceRegistered}) =>
      jsonFaceRegistered
          ? FaceRegistrationStatus.registered
          : FaceRegistrationStatus.notRegistered;
}
