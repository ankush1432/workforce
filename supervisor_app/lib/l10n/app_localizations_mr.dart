// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'फेस अटेंडन्स सुपरव्हायझर';

  @override
  String get home => 'होम';

  @override
  String get workforceAttendance => 'वर्कफोर्स हजेरी';

  @override
  String get viewTeamRecordAttendance => 'टीम पहा आणि हजेरी नोंदवा';

  @override
  String get companyAnnouncementsSchedules => 'कंपनी जाहिराती आणि वेळापत्रक';

  @override
  String get pastCheckInsCheckOuts => 'गेलेले चेक-इन आणि चेक-आउट';

  @override
  String get faceRegistrationInfo => 'चेहरा नोंदणी आणि सत्यापन प्रत्येक कर्मचारीच्या प्रोफाइलवरून होते.';

  @override
  String get scanFaceToMark => 'चेहरा स्कॅन करा';

  @override
  String get events => 'इव्हेंट्स';

  @override
  String get supervisorLogin => 'सुपरव्हायझर लॉगिन';

  @override
  String get signIn => 'साइन इन';

  @override
  String cannotReachApi(Object baseUrl) {
    return 'API शी जोडता आले नाही $baseUrl वर. सुनिश्चित करा की Laravel तुमच्या PC वर चालू आहे: php artisan serve --host=0.0.0.0 --port=8000';
  }

  @override
  String get login => 'लॉगिन';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get loginButton => 'लॉगिन';

  @override
  String get sessionExpired => 'सत्र समाप्त झाले आहे. कृपया पुन्हा लॉगिन करा.';

  @override
  String get loginFailed => 'लॉगिन अयशस्वी';

  @override
  String get loginSuccess => 'लॉगिन यशस्वी';

  @override
  String get dashboard => 'डॅशबोर्ड';

  @override
  String get employees => 'कर्मचारी';

  @override
  String get attendance => 'हजेरी';

  @override
  String get attendanceHistory => 'हजेरी इतिहास';

  @override
  String get todayAttendance => 'आजची हजेरी';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा निवडा';

  @override
  String get checkIn => 'चेक-इन';

  @override
  String get checkOut => 'चेक-आउट';

  @override
  String get checkInSuccess => 'चेक-इन यशस्वी';

  @override
  String get checkOutSuccess => 'चेक-आउट यशस्वी';

  @override
  String get checkInFailed => 'चेक-इन अयशस्वी';

  @override
  String get checkOutFailed => 'चेक-आउट अयशस्वी';

  @override
  String get alreadyCheckedIn => 'आधीच चेक-इन झाले आहे';

  @override
  String get alreadyCheckedOut => 'आधीच चेक-आउट झाले आहे';

  @override
  String get mustCheckInFirst => 'कर्मचारीला प्रथम चेक-इन करावे लागेल';

  @override
  String get registerFace => 'चेहरा नोंदणी करा';

  @override
  String get verifyFace => 'चेहरा सत्यापित करा';

  @override
  String get faceRegistered => 'चेहरा नोंदणी झाला';

  @override
  String get faceNotRegistered => 'चेहरा नोंदणी झालेला नाही';

  @override
  String get registerFaceSuccess => 'चेहरा यशस्वीरित्या नोंदणी झाला';

  @override
  String get registerFaceFailed => 'चेहरा नोंदणी अयशस्वी';

  @override
  String get duplicateFaceDetected => 'डुप्लिकेट चेहरा आढळला';

  @override
  String get cameraPermissionRequired => 'कॅमेऱ्या परवानगी आवश्यक आहे';

  @override
  String get enableCameraInSettings => 'सेटिंग्समध्ये कॅमेऱ्या सक्षम करा';

  @override
  String get cameraPermissionDenied => 'कॅमेऱ्या परवानगी नाकारली';

  @override
  String get cameraPermissionPermanentlyDenied => 'कॅमेऱ्या परवानगी कायमस्वरूपी नाकारली';

  @override
  String get allowCameraPermission => 'चेहरा ओळख वापरण्यासाठी कॅमेऱ्या परवानगी द्या';

  @override
  String get faceVerified => 'चेहरा सत्यापित';

  @override
  String get faceNotMatched => 'चेहरा ओळखला गेला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get faceMismatch => 'चेहरा जुळत नाही';

  @override
  String get faceMatchedSuccessfully => 'चेहरा यशस्वीरित्या जुळला';

  @override
  String get processingAttendance => 'हजेरी प्रक्रिया';

  @override
  String get moveCloserToCamera => 'कॅमेऱ्याजवळ या';

  @override
  String get moveSlightlyBack => 'थोडे मागे जा';

  @override
  String get lightingTooDark => 'प्रकाशपुरवठा खूप कमी आहे';

  @override
  String get lightingTooBright => 'प्रकाशपुरवठा खूप जास्त आहे';

  @override
  String get faceTheCameraDirectly => 'थेट कॅमेऱ्याकडे पहा';

  @override
  String get multipleFacesDetected => 'अनेक चेहरे आढळले';

  @override
  String get noFaceDetected => 'कोणताही चेहरा आढळला नाही';

  @override
  String get completeLivenessChecksFirst => 'प्रथम लाइवनेस तपासणी पूर्ण करा';

  @override
  String get alignFace => 'चेहरा संरेखित करा आणि कॅप्चर करा';

  @override
  String get centerYourFace => 'तुमचा चेहरा मध्यभागी ठेवा';

  @override
  String get processing => 'प्रक्रिया';

  @override
  String get loading => 'लोड होत आहे';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get ok => 'ठीक आहे';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get confirm => 'पुष्टी करा';

  @override
  String get yes => 'होय';

  @override
  String get no => 'नाही';

  @override
  String get close => 'बंद करा';

  @override
  String get save => 'जतन करा';

  @override
  String get delete => 'हटवा';

  @override
  String get edit => 'संपादित करा';

  @override
  String get search => 'शोधा';

  @override
  String get filter => 'फिल्टर';

  @override
  String get sort => 'क्रमवारी लावा';

  @override
  String get employeeDetails => 'कर्मचारी तपशील';

  @override
  String get error => 'त्रुटी';

  @override
  String get employeeName => 'कर्मचारीचे नाव';

  @override
  String get employeeCode => 'कर्मचारी कोड';

  @override
  String get department => 'विभाग';

  @override
  String get designation => 'पद';

  @override
  String get site => 'स्थळ';

  @override
  String get shift => 'शिफ्ट';

  @override
  String get supervisor => 'पर्यवेक्षक';

  @override
  String get activeStatus => 'सक्रिय स्थिती';

  @override
  String get faceRegistrationStatus => 'चेहरा नोंदणी स्थिती';

  @override
  String get phone => 'फोन';

  @override
  String get checkInTime => 'चेक-इन वेळ';

  @override
  String get checkOutTime => 'चेक-आउट वेळ';

  @override
  String get employeeInformation => 'कर्मचारी माहिती';

  @override
  String get departmentDesignation => 'विभाग आणि पद';

  @override
  String get siteInformation => 'स्थळ माहिती';

  @override
  String get siteName => 'स्थळाचे नाव';

  @override
  String get siteAddress => 'स्थळाचा पत्ता';

  @override
  String get shiftInformation => 'शिफ्ट माहिती';

  @override
  String get shiftName => 'शिफ्टचे नाव';

  @override
  String get shiftTime => 'शिफ्ट वेळ';

  @override
  String get supervisorInformation => 'पर्यवेक्षक माहिती';

  @override
  String get supervisorName => 'पर्यवेक्षकाचे नाव';

  @override
  String get copiedToClipboard => 'क्लिपबोर्डवर कॉपी केले';

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get checkInSuccessful => 'चेक-इन यशस्वी';

  @override
  String get checkOutSuccessful => 'चेक-आउट यशस्वी';

  @override
  String attendanceWillContinue(Object action) {
    return 'हजेरी $action स्वयंचालितपणे सुरू राहील.';
  }

  @override
  String get verifyAndCheckIn => 'सत्यापित करा आणि चेक-इन करा';

  @override
  String get verifyAndCheckOut => 'सत्यापित करा आणि चेक-आउट करा';

  @override
  String get enableCameraInSystemSettings => 'सिस्टम सेटिंग्समध्ये कॅमेऱ्या सक्षम करा';

  @override
  String get faceModelMissing => 'चेहरा मॉडेल आढळले नाही. assets/models/facenet.tflite जोडा';

  @override
  String initFailed(Object error) {
    return 'सुरुवात अयशस्वी: $error';
  }

  @override
  String get noCameraAvailable => 'कोणताही कॅमेऱ्या उपलब्ध नाही';

  @override
  String cameraInitializationFailed(Object error) {
    return 'कॅमेऱ्या सुरुवात अयशस्वी: $error';
  }

  @override
  String get failedToSwitchCamera => 'कॅमेऱ्या बदलण्यात अयशस्वी';

  @override
  String get registrationWillContinueToCheckIn => 'नोंदणी स्वयंचालितपणे चेक-इन सुरू राहील.';

  @override
  String get registrationWillContinueToCheckOut => 'नोंदणी स्वयंचालितपणे चेक-आउट सुरू राहील.';

  @override
  String get positionFaceInsideCircle => 'चेहरा वर्तुळ मार्गदर्शकाच्या आत ठेवा.';

  @override
  String get captureAndRegister => 'कॅप्चर आणि नोंदणी करा';

  @override
  String get thisFaceAlreadyRegisteredToAnotherEmployee => 'हा चेहरा आधीच दुसऱ्या कर्मचाऱ्यासाठी नोंदणी झाला आहे';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नाही';

  @override
  String get serverError => 'सर्व्हर त्रुटी. कृपया नंतर प्रयत्न करा';

  @override
  String get timeout => 'विनंती वेळ समाप्त झाली. कृपया पुन्हा प्रयत्न करा';

  @override
  String get unauthorized => 'अनधिकृत';

  @override
  String get forbidden => 'प्रवेश निषिद्ध';

  @override
  String get notFound => 'संसाधन सापडले नाही';

  @override
  String get validationError => 'सत्यापन त्रुटी';

  @override
  String get unknownError => 'एक अनपेक्षित त्रुटी आली';

  @override
  String get confidence => 'विश्वास';

  @override
  String get time => 'वेळ';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get refresh => 'रिफ्रेश';

  @override
  String get noEmployeesFound => 'कोणतेही कर्मचारी आढळले नाहीत';

  @override
  String get register => 'नोंदणी करा';

  @override
  String get noEventsAvailable => 'कोणतेही इव्हेंट्स उपलब्ध नाहीत';

  @override
  String get noEventsPublished => 'सध्या कोणतीही प्रकाशित इव्हेंट्स नाहीत.';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get apiUrl => 'API URL';

  @override
  String get noAttendanceRecordsYet => 'अजून हजेरी नोंदी नाहीत';

  @override
  String get unknownDate => 'अज्ञात तारीख';

  @override
  String get employeeMustCheckInFirst => 'कर्मचारीला प्रथम चेक-इन करावे लागेल';

  @override
  String get eventDetails => 'इव्हेंट तपशील';

  @override
  String get notifications => 'सूचना';

  @override
  String get noNotifications => 'कोणत्याही सूचना नाहीत';

  @override
  String get wageSummary => 'वेत सारांश';

  @override
  String get monthlyWageSummariesAppearHere => 'मासिक वेत सारांश येथे दिसतील';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get marathi => 'मराठी';
}
