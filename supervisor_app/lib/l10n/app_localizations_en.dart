// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Face Attendance Supervisor';

  @override
  String get home => 'Home';

  @override
  String get workforceAttendance => 'Workforce Attendance';

  @override
  String get viewTeamRecordAttendance => 'View team & record attendance';

  @override
  String get companyAnnouncementsSchedules => 'Company announcements & schedules';

  @override
  String get pastCheckInsCheckOuts => 'Past check-ins and check-outs';

  @override
  String get faceRegistrationInfo => 'Face registration and verification happen from each employee\'s profile.';

  @override
  String get scanFaceToMark => 'Scan face to mark';

  @override
  String get events => 'Events';

  @override
  String get supervisorLogin => 'Supervisor Login';

  @override
  String get signIn => 'Sign In';

  @override
  String cannotReachApi(Object baseUrl) {
    return 'Cannot reach API at $baseUrl. Ensure Laravel runs on your PC: php artisan serve --host=0.0.0.0 --port=8000';
  }

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get sessionExpired => 'Session expired. Please login again.';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get employees => 'Employees';

  @override
  String get attendance => 'Attendance';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get todayAttendance => 'Today Attendance';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkOut => 'Check Out';

  @override
  String get checkInSuccess => 'Check-in successful';

  @override
  String get checkOutSuccess => 'Check-out successful';

  @override
  String get checkInFailed => 'Check In Failed';

  @override
  String get checkOutFailed => 'Check Out Failed';

  @override
  String get alreadyCheckedIn => 'Already Checked In';

  @override
  String get alreadyCheckedOut => 'Already Checked Out';

  @override
  String get mustCheckInFirst => 'Employee must check in first';

  @override
  String get registerFace => 'Register Face';

  @override
  String get verifyFace => 'Verify Face';

  @override
  String get faceRegistered => 'Face Registered';

  @override
  String get faceNotRegistered => 'Face Not Registered';

  @override
  String get registerFaceSuccess => 'Face registered successfully';

  @override
  String get registerFaceFailed => 'Face registration failed';

  @override
  String get duplicateFaceDetected => 'Duplicate Face Detected';

  @override
  String get cameraPermissionRequired => 'Camera permission is required';

  @override
  String get enableCameraInSettings => 'Enable Camera In Settings';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get cameraPermissionPermanentlyDenied => 'Camera permission permanently denied';

  @override
  String get allowCameraPermission => 'Allow camera permission to use face recognition';

  @override
  String get faceVerified => 'Face Verified';

  @override
  String get faceNotMatched => 'Face not recognized. Please try again.';

  @override
  String get faceMismatch => 'Face Mismatch';

  @override
  String get faceMatchedSuccessfully => 'Face Matched Successfully';

  @override
  String get processingAttendance => 'Processing Attendance';

  @override
  String get moveCloserToCamera => 'Move Closer To Camera';

  @override
  String get moveSlightlyBack => 'Move Slightly Back';

  @override
  String get lightingTooDark => 'Lighting Too Dark';

  @override
  String get lightingTooBright => 'Lighting Too Bright';

  @override
  String get faceTheCameraDirectly => 'Face The Camera Directly';

  @override
  String get multipleFacesDetected => 'Multiple Faces Detected';

  @override
  String get noFaceDetected => 'No Face Detected';

  @override
  String get completeLivenessChecksFirst => 'Complete Liveness Checks First';

  @override
  String get alignFace => 'Align face and capture';

  @override
  String get centerYourFace => 'Center your face';

  @override
  String get processing => 'Processing';

  @override
  String get loading => 'Loading';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get employeeDetails => 'Employee Details';

  @override
  String get error => 'Error';

  @override
  String get employeeName => 'Employee Name';

  @override
  String get employeeCode => 'Employee Code';

  @override
  String get department => 'Department';

  @override
  String get designation => 'Designation';

  @override
  String get site => 'Site';

  @override
  String get shift => 'Shift';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get activeStatus => 'Active Status';

  @override
  String get faceRegistrationStatus => 'Face Registration Status';

  @override
  String get phone => 'Phone';

  @override
  String get checkInTime => 'Check-in Time';

  @override
  String get checkOutTime => 'Check-out Time';

  @override
  String get employeeInformation => 'Employee Information';

  @override
  String get departmentDesignation => 'Department & Designation';

  @override
  String get siteInformation => 'Site Information';

  @override
  String get siteName => 'Site Name';

  @override
  String get siteAddress => 'Site Address';

  @override
  String get shiftInformation => 'Shift Information';

  @override
  String get shiftName => 'Shift Name';

  @override
  String get shiftTime => 'Shift Time';

  @override
  String get supervisorInformation => 'Supervisor Information';

  @override
  String get supervisorName => 'Supervisor Name';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get checkInSuccessful => 'Check In Successful';

  @override
  String get checkOutSuccessful => 'Check Out Successful';

  @override
  String attendanceWillContinue(Object action) {
    return 'Attendance will continue to $action automatically.';
  }

  @override
  String get verifyAndCheckIn => 'Verify & Check In';

  @override
  String get verifyAndCheckOut => 'Verify & Check Out';

  @override
  String get enableCameraInSystemSettings => 'Enable camera in system settings';

  @override
  String get faceModelMissing => 'Face model missing. Add assets/models/facenet.tflite';

  @override
  String initFailed(Object error) {
    return 'Init failed: $error';
  }

  @override
  String get noCameraAvailable => 'No camera available';

  @override
  String cameraInitializationFailed(Object error) {
    return 'Camera initialization failed: $error';
  }

  @override
  String get failedToSwitchCamera => 'Failed to switch camera';

  @override
  String get registrationWillContinueToCheckIn => 'Registration will continue to check-in automatically.';

  @override
  String get registrationWillContinueToCheckOut => 'Registration will continue to check-out automatically.';

  @override
  String get positionFaceInsideCircle => 'Position the face inside the circle guide.';

  @override
  String get captureAndRegister => 'Capture & Register';

  @override
  String get thisFaceAlreadyRegisteredToAnotherEmployee => 'This face is already registered to another employee';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get serverError => 'Server error. Please try again later';

  @override
  String get timeout => 'Request timed out. Please try again';

  @override
  String get unauthorized => 'Unauthorized';

  @override
  String get forbidden => 'Access forbidden';

  @override
  String get notFound => 'Resource not found';

  @override
  String get validationError => 'Validation error';

  @override
  String get unknownError => 'An unexpected error occurred';

  @override
  String get confidence => 'Confidence';

  @override
  String get time => 'Time';

  @override
  String get profile => 'Profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get refresh => 'Refresh';

  @override
  String get noEmployeesFound => 'No employees found';

  @override
  String get register => 'Register';

  @override
  String get noEventsAvailable => 'No Events Available';

  @override
  String get noEventsPublished => 'There are currently no published events.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get apiUrl => 'API URL';

  @override
  String get noAttendanceRecordsYet => 'No attendance records yet';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get employeeMustCheckInFirst => 'Employee must check in first';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get wageSummary => 'Wage Summary';

  @override
  String get monthlyWageSummariesAppearHere => 'Monthly wage summaries appear here';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get marathi => 'मराठी';
}
