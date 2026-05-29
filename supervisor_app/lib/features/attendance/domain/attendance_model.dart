class AttendanceModel {
  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    this.checkInAt,
    this.checkOutAt,
    this.status,
    this.workedMinutes,
    this.employeeName,
    this.shiftName,
    this.siteName,
  });

  final int id;
  final int employeeId;
  final String attendanceDate;
  final String? checkInAt;
  final String? checkOutAt;
  final String? status;
  final int? workedMinutes;
  final String? employeeName;
  final String? shiftName;
  final String? siteName;

  bool get hasCheckIn => checkInAt != null;
  bool get hasCheckOut => checkOutAt != null;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] as Map<String, dynamic>?;
    final shift = json['shift'] as Map<String, dynamic>?;
    final site = json['site'] as Map<String, dynamic>?;

    return AttendanceModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      attendanceDate: json['attendance_date'] as String? ?? '',
      checkInAt: json['check_in_at'] as String?,
      checkOutAt: json['check_out_at'] as String?,
      status: json['status'] as String?,
      workedMinutes: json['worked_minutes'] as int?,
      employeeName: employee?['full_name'] as String?,
      shiftName: shift?['name'] as String?,
      siteName: site?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'attendance_date': attendanceDate,
        'check_in_at': checkInAt,
        'check_out_at': checkOutAt,
        'status': status,
        'worked_minutes': workedMinutes,
        'employee_name': employeeName,
        'shift_name': shiftName,
        'site_name': siteName,
      };
}
