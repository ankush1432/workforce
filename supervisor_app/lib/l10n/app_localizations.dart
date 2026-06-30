import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Face Attendance Supervisor'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @workforceAttendance.
  ///
  /// In en, this message translates to:
  /// **'Workforce Attendance'**
  String get workforceAttendance;

  /// No description provided for @viewTeamRecordAttendance.
  ///
  /// In en, this message translates to:
  /// **'View team & record attendance'**
  String get viewTeamRecordAttendance;

  /// No description provided for @companyAnnouncementsSchedules.
  ///
  /// In en, this message translates to:
  /// **'Company announcements & schedules'**
  String get companyAnnouncementsSchedules;

  /// No description provided for @pastCheckInsCheckOuts.
  ///
  /// In en, this message translates to:
  /// **'Past check-ins and check-outs'**
  String get pastCheckInsCheckOuts;

  /// No description provided for @faceRegistrationInfo.
  ///
  /// In en, this message translates to:
  /// **'Face registration and verification happen from each employee\'s profile.'**
  String get faceRegistrationInfo;

  /// No description provided for @scanFaceToMark.
  ///
  /// In en, this message translates to:
  /// **'Scan face to mark'**
  String get scanFaceToMark;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @supervisorLogin.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Login'**
  String get supervisorLogin;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @cannotReachApi.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach API at {baseUrl}. Ensure Laravel runs on your PC: php artisan serve --host=0.0.0.0 --port=8000'**
  String cannotReachApi(Object baseUrl);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistory;

  /// No description provided for @todayAttendance.
  ///
  /// In en, this message translates to:
  /// **'Today Attendance'**
  String get todayAttendance;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get checkOut;

  /// No description provided for @checkInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check-in successful'**
  String get checkInSuccess;

  /// No description provided for @checkOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check-out successful'**
  String get checkOutSuccess;

  /// No description provided for @checkInFailed.
  ///
  /// In en, this message translates to:
  /// **'Check In Failed'**
  String get checkInFailed;

  /// No description provided for @checkOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Check Out Failed'**
  String get checkOutFailed;

  /// No description provided for @alreadyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Already Checked In'**
  String get alreadyCheckedIn;

  /// No description provided for @alreadyCheckedOut.
  ///
  /// In en, this message translates to:
  /// **'Already Checked Out'**
  String get alreadyCheckedOut;

  /// No description provided for @mustCheckInFirst.
  ///
  /// In en, this message translates to:
  /// **'Employee must check in first'**
  String get mustCheckInFirst;

  /// No description provided for @registerFace.
  ///
  /// In en, this message translates to:
  /// **'Register Face'**
  String get registerFace;

  /// No description provided for @verifyFace.
  ///
  /// In en, this message translates to:
  /// **'Verify Face'**
  String get verifyFace;

  /// No description provided for @faceRegistered.
  ///
  /// In en, this message translates to:
  /// **'Face Registered'**
  String get faceRegistered;

  /// No description provided for @faceNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Face Not Registered'**
  String get faceNotRegistered;

  /// No description provided for @registerFaceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Face registered successfully'**
  String get registerFaceSuccess;

  /// No description provided for @registerFaceFailed.
  ///
  /// In en, this message translates to:
  /// **'Face registration failed'**
  String get registerFaceFailed;

  /// No description provided for @duplicateFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Face Detected'**
  String get duplicateFaceDetected;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required'**
  String get cameraPermissionRequired;

  /// No description provided for @enableCameraInSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable Camera In Settings'**
  String get enableCameraInSettings;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission permanently denied'**
  String get cameraPermissionPermanentlyDenied;

  /// No description provided for @allowCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow camera permission to use face recognition'**
  String get allowCameraPermission;

  /// No description provided for @faceVerified.
  ///
  /// In en, this message translates to:
  /// **'Face Verified'**
  String get faceVerified;

  /// No description provided for @faceNotMatched.
  ///
  /// In en, this message translates to:
  /// **'Face not recognized. Please try again.'**
  String get faceNotMatched;

  /// No description provided for @faceMismatch.
  ///
  /// In en, this message translates to:
  /// **'Face Mismatch'**
  String get faceMismatch;

  /// No description provided for @faceMatchedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Face Matched Successfully'**
  String get faceMatchedSuccessfully;

  /// No description provided for @processingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Processing Attendance'**
  String get processingAttendance;

  /// No description provided for @moveCloserToCamera.
  ///
  /// In en, this message translates to:
  /// **'Move Closer To Camera'**
  String get moveCloserToCamera;

  /// No description provided for @moveSlightlyBack.
  ///
  /// In en, this message translates to:
  /// **'Move Slightly Back'**
  String get moveSlightlyBack;

  /// No description provided for @lightingTooDark.
  ///
  /// In en, this message translates to:
  /// **'Lighting Too Dark'**
  String get lightingTooDark;

  /// No description provided for @lightingTooBright.
  ///
  /// In en, this message translates to:
  /// **'Lighting Too Bright'**
  String get lightingTooBright;

  /// No description provided for @faceTheCameraDirectly.
  ///
  /// In en, this message translates to:
  /// **'Face The Camera Directly'**
  String get faceTheCameraDirectly;

  /// No description provided for @multipleFacesDetected.
  ///
  /// In en, this message translates to:
  /// **'Multiple Faces Detected'**
  String get multipleFacesDetected;

  /// No description provided for @noFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'No Face Detected'**
  String get noFaceDetected;

  /// No description provided for @completeLivenessChecksFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete Liveness Checks First'**
  String get completeLivenessChecksFirst;

  /// No description provided for @alignFace.
  ///
  /// In en, this message translates to:
  /// **'Align face and capture'**
  String get alignFace;

  /// No description provided for @centerYourFace.
  ///
  /// In en, this message translates to:
  /// **'Center your face'**
  String get centerYourFace;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @employeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Employee Details'**
  String get employeeDetails;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @employeeName.
  ///
  /// In en, this message translates to:
  /// **'Employee Name'**
  String get employeeName;

  /// No description provided for @employeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get employeeCode;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @site.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get site;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get activeStatus;

  /// No description provided for @faceRegistrationStatus.
  ///
  /// In en, this message translates to:
  /// **'Face Registration Status'**
  String get faceRegistrationStatus;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @checkInTime.
  ///
  /// In en, this message translates to:
  /// **'Check-in Time'**
  String get checkInTime;

  /// No description provided for @checkOutTime.
  ///
  /// In en, this message translates to:
  /// **'Check-out Time'**
  String get checkOutTime;

  /// No description provided for @employeeInformation.
  ///
  /// In en, this message translates to:
  /// **'Employee Information'**
  String get employeeInformation;

  /// No description provided for @departmentDesignation.
  ///
  /// In en, this message translates to:
  /// **'Department & Designation'**
  String get departmentDesignation;

  /// No description provided for @siteInformation.
  ///
  /// In en, this message translates to:
  /// **'Site Information'**
  String get siteInformation;

  /// No description provided for @siteName.
  ///
  /// In en, this message translates to:
  /// **'Site Name'**
  String get siteName;

  /// No description provided for @siteAddress.
  ///
  /// In en, this message translates to:
  /// **'Site Address'**
  String get siteAddress;

  /// No description provided for @shiftInformation.
  ///
  /// In en, this message translates to:
  /// **'Shift Information'**
  String get shiftInformation;

  /// No description provided for @shiftName.
  ///
  /// In en, this message translates to:
  /// **'Shift Name'**
  String get shiftName;

  /// No description provided for @shiftTime.
  ///
  /// In en, this message translates to:
  /// **'Shift Time'**
  String get shiftTime;

  /// No description provided for @supervisorInformation.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Information'**
  String get supervisorInformation;

  /// No description provided for @supervisorName.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Name'**
  String get supervisorName;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @checkInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check In Successful'**
  String get checkInSuccessful;

  /// No description provided for @checkOutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check Out Successful'**
  String get checkOutSuccessful;

  /// No description provided for @attendanceWillContinue.
  ///
  /// In en, this message translates to:
  /// **'Attendance will continue to {action} automatically.'**
  String attendanceWillContinue(Object action);

  /// No description provided for @verifyAndCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Verify & Check In'**
  String get verifyAndCheckIn;

  /// No description provided for @verifyAndCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Verify & Check Out'**
  String get verifyAndCheckOut;

  /// No description provided for @enableCameraInSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable camera in system settings'**
  String get enableCameraInSystemSettings;

  /// No description provided for @faceModelMissing.
  ///
  /// In en, this message translates to:
  /// **'Face model missing. Add assets/models/facenet.tflite'**
  String get faceModelMissing;

  /// No description provided for @initFailed.
  ///
  /// In en, this message translates to:
  /// **'Init failed: {error}'**
  String initFailed(Object error);

  /// No description provided for @noCameraAvailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get noCameraAvailable;

  /// No description provided for @cameraInitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera initialization failed: {error}'**
  String cameraInitializationFailed(Object error);

  /// No description provided for @failedToSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch camera'**
  String get failedToSwitchCamera;

  /// No description provided for @registrationWillContinueToCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Registration will continue to check-in automatically.'**
  String get registrationWillContinueToCheckIn;

  /// No description provided for @registrationWillContinueToCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Registration will continue to check-out automatically.'**
  String get registrationWillContinueToCheckOut;

  /// No description provided for @positionFaceInsideCircle.
  ///
  /// In en, this message translates to:
  /// **'Position the face inside the circle guide.'**
  String get positionFaceInsideCircle;

  /// No description provided for @captureAndRegister.
  ///
  /// In en, this message translates to:
  /// **'Capture & Register'**
  String get captureAndRegister;

  /// No description provided for @thisFaceAlreadyRegisteredToAnotherEmployee.
  ///
  /// In en, this message translates to:
  /// **'This face is already registered to another employee'**
  String get thisFaceAlreadyRegisteredToAnotherEmployee;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later'**
  String get serverError;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again'**
  String get timeout;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Access forbidden'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get notFound;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unknownError;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noEmployeesFound.
  ///
  /// In en, this message translates to:
  /// **'No employees found'**
  String get noEmployeesFound;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @noEventsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Events Available'**
  String get noEventsAvailable;

  /// No description provided for @noEventsPublished.
  ///
  /// In en, this message translates to:
  /// **'There are currently no published events.'**
  String get noEventsPublished;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @apiUrl.
  ///
  /// In en, this message translates to:
  /// **'API URL'**
  String get apiUrl;

  /// No description provided for @noAttendanceRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet'**
  String get noAttendanceRecordsYet;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @employeeMustCheckInFirst.
  ///
  /// In en, this message translates to:
  /// **'Employee must check in first'**
  String get employeeMustCheckInFirst;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @wageSummary.
  ///
  /// In en, this message translates to:
  /// **'Wage Summary'**
  String get wageSummary;

  /// No description provided for @monthlyWageSummariesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Monthly wage summaries appear here'**
  String get monthlyWageSummariesAppearHere;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'mr': return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
