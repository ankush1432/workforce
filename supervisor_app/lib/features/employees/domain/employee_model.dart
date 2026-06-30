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
    this.email,
    this.phone,
    this.faceRegistrationStatus,
    this.isActive,
    this.site,
    this.supervisor,
    this.departmentRelation,
    this.designationRelation,
    this.shift,
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
  final String? email;
  final String? phone;
  final String? faceRegistrationStatus;
  final bool? isActive;
  final Site? site;
  final Supervisor? supervisor;
  final DepartmentRelation? departmentRelation;
  final DesignationRelation? designationRelation;
  final Shift? shift;

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
      department: json['department_relation'] is Map
          ? json['department_relation']['name'] as String?
          : json['department_relation'] as String?,
      faceRegistered: registered,
      faceStatus: registered && status == FaceRegistrationStatus.notRegistered
          ? FaceRegistrationStatus.registered
          : status,
      embeddingExists: json['embedding_exists'] as bool? ?? registered,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      faceRegistrationStatus: json['face_registration_status'] as String?,
      isActive: json['is_active'] as bool?,
      site: json['site'] != null && json['site'] is Map
          ? Site.fromJson(Map<String, dynamic>.from(json['site'] as Map))
          : null,
      supervisor: json['supervisor'] != null && json['supervisor'] is Map
          ? Supervisor.fromJson(Map<String, dynamic>.from(json['supervisor'] as Map))
          : null,
      departmentRelation: json['department_relation'] is Map
          ? DepartmentRelation.fromJson(Map<String, dynamic>.from(json['department_relation'] as Map))
          : null,
      designationRelation: json['designation_relation'] != null && json['designation_relation'] is Map
          ? DesignationRelation.fromJson(Map<String, dynamic>.from(json['designation_relation'] as Map))
          : null,
      shift: json['shift'] != null && json['shift'] is Map
          ? Shift.fromJson(Map<String, dynamic>.from(json['shift'] as Map))
          : null,
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
        'email': email,
        'phone': phone,
        'is_active': isActive,
        'site': site?.toJson(),
        'supervisor': supervisor?.toJson(),
        'department_relation': departmentRelation?.toJson(),
        'designation_relation': designationRelation?.toJson(),
        'shift': shift?.toJson(),
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
        email: email,
        phone: phone,
        faceRegistrationStatus: faceRegistrationStatus,
        isActive: isActive,
        site: site,
        supervisor: supervisor,
        departmentRelation: departmentRelation,
        designationRelation: designationRelation,
        shift: shift,
      );

  static FaceRegistrationStatus _statusFromLegacy({required bool jsonFaceRegistered}) =>
      jsonFaceRegistered
          ? FaceRegistrationStatus.registered
          : FaceRegistrationStatus.notRegistered;
}

class Site {
  Site({
    this.name,
    this.address,
  });

  factory Site.fromJson(Map<String, dynamic> json) => Site(
        name: json['name'] as String?,
        address: json['address'] as String?,
      );

  final String? name;
  final String? address;

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
      };
}

class Supervisor {
  Supervisor({
    this.fullName,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) => Supervisor(
        fullName: json['full_name'] as String?,
      );

  final String? fullName;

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
      };
}

class DepartmentRelation {
  DepartmentRelation({
    this.name,
  });

  factory DepartmentRelation.fromJson(Map<String, dynamic> json) => DepartmentRelation(
        name: json['name'] as String?,
      );

  final String? name;

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}

class DesignationRelation {
  DesignationRelation({
    this.title,
  });

  factory DesignationRelation.fromJson(Map<String, dynamic> json) => DesignationRelation(
        title: json['title'] as String?,
      );

  final String? title;

  Map<String, dynamic> toJson() => {
        'title': title,
      };
}

class Shift {
  Shift({
    this.name,
    this.startTime,
    this.endTime,
  });

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        name: json['name'] as String?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
      );

  final String? name;
  final String? startTime;
  final String? endTime;

  Map<String, dynamic> toJson() => {
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
      };
}
