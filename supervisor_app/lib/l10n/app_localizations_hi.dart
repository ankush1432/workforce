// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'फेस अटेंडेंस सुपरवाइजर';

  @override
  String get home => 'होम';

  @override
  String get workforceAttendance => 'वर्कफोर्स उपस्थिति';

  @override
  String get viewTeamRecordAttendance => 'टीम देखें और उपस्थिति रिकॉर्ड करें';

  @override
  String get companyAnnouncementsSchedules => 'कंपनी घोषणाएं और समयसारणी';

  @override
  String get pastCheckInsCheckOuts => 'पिछले चेक-इन और चेक-आउट';

  @override
  String get faceRegistrationInfo => 'चेहरा पंजीकरण और सत्यापन प्रत्येक कर्मचारी की प्रोफाइल से होता है।';

  @override
  String get scanFaceToMark => 'चेहरा स्कैन करें';

  @override
  String get events => 'इवेंट्स';

  @override
  String get supervisorLogin => 'सुपरवाइजर लॉगिन';

  @override
  String get signIn => 'साइन इन';

  @override
  String cannotReachApi(Object baseUrl) {
    return 'API से नहीं जुड़ा जा सका $baseUrl पर। सुनिश्चित करें कि Laravel आपके PC पर चल रहा है: php artisan serve --host=0.0.0.0 --port=8000';
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
  String get sessionExpired => 'सत्र समाप्त हो गया। कृपया पुनः लॉगिन करें।';

  @override
  String get loginFailed => 'लॉगिन विफल';

  @override
  String get loginSuccess => 'लॉगिन सफल';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get employees => 'कर्मचारी';

  @override
  String get attendance => 'उपस्थिति';

  @override
  String get attendanceHistory => 'उपस्थिति इतिहास';

  @override
  String get todayAttendance => 'आज की उपस्थिति';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get checkIn => 'चेक-इन';

  @override
  String get checkOut => 'चेक-आउट';

  @override
  String get checkInSuccess => 'चेक-इन सफल';

  @override
  String get checkOutSuccess => 'चेक-आउट सफल';

  @override
  String get checkInFailed => 'चेक-इन विफल';

  @override
  String get checkOutFailed => 'चेक-आउट विफल';

  @override
  String get alreadyCheckedIn => 'पहले से चेक-इन हो चुका है';

  @override
  String get alreadyCheckedOut => 'पहले से चेक-आउट हो चुका है';

  @override
  String get mustCheckInFirst => 'कर्मचारी को पहले चेक-इन करना होगा';

  @override
  String get registerFace => 'चेहरा पंजीकृत करें';

  @override
  String get verifyFace => 'चेहरा सत्यापित करें';

  @override
  String get faceRegistered => 'चेहरा पंजीकृत';

  @override
  String get faceNotRegistered => 'चेहरा पंजीकृत नहीं';

  @override
  String get registerFaceSuccess => 'चेहरा सफलतापूर्वक पंजीकृत';

  @override
  String get registerFaceFailed => 'चेहरा पंजीकरण विफल';

  @override
  String get duplicateFaceDetected => 'डुप्लिकेट चेहरा पाया गया';

  @override
  String get cameraPermissionRequired => 'कैमरा अनुमति आवश्यक है';

  @override
  String get enableCameraInSettings => 'सेटिंग्स में कैमरा सक्षम करें';

  @override
  String get cameraPermissionDenied => 'कैमरा अनुमति अस्वीकृत';

  @override
  String get cameraPermissionPermanentlyDenied => 'कैमरा अनुमति स्थायी रूप से अस्वीकृत';

  @override
  String get allowCameraPermission => 'चेहरा पहचान का उपयोग करने के लिए कैमरा अनुमति दें';

  @override
  String get faceVerified => 'चेहरा सत्यापित';

  @override
  String get faceNotMatched => 'चेहरा पहचाना नहीं गया। कृपया पुनः प्रयास करें।';

  @override
  String get faceMismatch => 'चेहरा मेल नहीं खाता';

  @override
  String get faceMatchedSuccessfully => 'चेहरा सफलतापूर्वक मेल खाता';

  @override
  String get processingAttendance => 'उपस्थिति प्रसंस्करण';

  @override
  String get moveCloserToCamera => 'कैमरे के करीब आएं';

  @override
  String get moveSlightlyBack => 'थोड़ा पीछे जाएं';

  @override
  String get lightingTooDark => 'रोशनी बहुत कम है';

  @override
  String get lightingTooBright => 'रोशनी बहुत अधिक है';

  @override
  String get faceTheCameraDirectly => 'सीधे कैमरे का सामना करें';

  @override
  String get multipleFacesDetected => 'कई चेहरे पाए गए';

  @override
  String get noFaceDetected => 'कोई चेहरा नहीं पाया गया';

  @override
  String get completeLivenessChecksFirst => 'पहले लाइवनेस जांच पूरी करें';

  @override
  String get alignFace => 'चेहरा संरेखित करें और कैप्चर करें';

  @override
  String get centerYourFace => 'अपना चेहरा केंद्र में रखें';

  @override
  String get processing => 'प्रसंस्करण';

  @override
  String get loading => 'लोड हो रहा है';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get close => 'बंद करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get search => 'खोजें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get sort => 'क्रमबद्ध करें';

  @override
  String get employeeDetails => 'कर्मचारी विवरण';

  @override
  String get error => 'त्रुटि';

  @override
  String get employeeName => 'कर्मचारी का नाम';

  @override
  String get employeeCode => 'कर्मचारी कोड';

  @override
  String get department => 'विभाग';

  @override
  String get designation => 'पद';

  @override
  String get site => 'स्थल';

  @override
  String get shift => 'शिफ्ट';

  @override
  String get supervisor => 'पर्यवेक्षक';

  @override
  String get activeStatus => 'सक्रिय स्थिति';

  @override
  String get faceRegistrationStatus => 'चेहरा पंजीकरण स्थिति';

  @override
  String get phone => 'फ़ोन';

  @override
  String get checkInTime => 'चेक-इन समय';

  @override
  String get checkOutTime => 'चेक-आउट समय';

  @override
  String get employeeInformation => 'कर्मचारी जानकारी';

  @override
  String get departmentDesignation => 'विभाग और पद';

  @override
  String get siteInformation => 'स्थल जानकारी';

  @override
  String get siteName => 'स्थल का नाम';

  @override
  String get siteAddress => 'स्थल का पता';

  @override
  String get shiftInformation => 'शिफ्ट जानकारी';

  @override
  String get shiftName => 'शिफ्ट का नाम';

  @override
  String get shiftTime => 'शिफ्ट समय';

  @override
  String get supervisorInformation => 'पर्यवेक्षक जानकारी';

  @override
  String get supervisorName => 'पर्यवेक्षक का नाम';

  @override
  String get copiedToClipboard => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String get checkInSuccessful => 'चेक-इन सफल';

  @override
  String get checkOutSuccessful => 'चेक-आउट सफल';

  @override
  String attendanceWillContinue(Object action) {
    return 'उपस्थिति $action स्वचालित रूप से जारी रहेगी।';
  }

  @override
  String get verifyAndCheckIn => 'सत्यापित करें और चेक-इन करें';

  @override
  String get verifyAndCheckOut => 'सत्यापित करें और चेक-आउट करें';

  @override
  String get enableCameraInSystemSettings => 'सिस्टम सेटिंग्स में कैमरा सक्षम करें';

  @override
  String get faceModelMissing => 'चेहरा मॉडल गायब है। assets/models/facenet.tflite जोड़ें';

  @override
  String initFailed(Object error) {
    return 'आरंभ विफल: $error';
  }

  @override
  String get noCameraAvailable => 'कोई कैमरा उपलब्ध नहीं';

  @override
  String cameraInitializationFailed(Object error) {
    return 'कैमरा आरंभ विफल: $error';
  }

  @override
  String get failedToSwitchCamera => 'कैमरा स्विच करने में विफल';

  @override
  String get registrationWillContinueToCheckIn => 'पंजीकरण स्वचालित रूप से चेक-इन जारी रहेगी।';

  @override
  String get registrationWillContinueToCheckOut => 'पंजीकरण स्वचालित रूप से चेक-आउट जारी रहेगी।';

  @override
  String get positionFaceInsideCircle => 'चेहरे को वृत्त गाइड के अंदर रखें।';

  @override
  String get captureAndRegister => 'कैप्चर और पंजीकृत करें';

  @override
  String get thisFaceAlreadyRegisteredToAnotherEmployee => 'यह चेहरा पहले से ही दूसरे कर्मचारी के लिए पंजीकृत है';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नहीं';

  @override
  String get serverError => 'सर्वर त्रुटि। कृपया बाद में प्रयास करें';

  @override
  String get timeout => 'अनुरोध समय सीमा समाप्त। कृपया पुनः प्रयास करें';

  @override
  String get unauthorized => 'अनधिकृत';

  @override
  String get forbidden => 'पहुंच निषिद्ध';

  @override
  String get notFound => 'संसाधन नहीं मिला';

  @override
  String get validationError => 'सत्यापन त्रुटि';

  @override
  String get unknownError => 'एक अनपेक्षित त्रुटि हुई';

  @override
  String get confidence => 'विश्वास';

  @override
  String get time => 'समय';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get refresh => 'रिफ्रेश';

  @override
  String get noEmployeesFound => 'कोई कर्मचारी नहीं मिला';

  @override
  String get register => 'पंजीकृत करें';

  @override
  String get noEventsAvailable => 'कोई इवेंट उपलब्ध नहीं';

  @override
  String get noEventsPublished => 'वर्तमान में कोई प्रकाशित इवेंट नहीं हैं।';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get apiUrl => 'API URL';

  @override
  String get noAttendanceRecordsYet => 'अभी तक कोई उपस्थिति रिकॉर्ड नहीं';

  @override
  String get unknownDate => 'अज्ञात तिथि';

  @override
  String get employeeMustCheckInFirst => 'कर्मचारी को पहले चेक-इन करना होगा';

  @override
  String get eventDetails => 'इवेंट विवरण';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get noNotifications => 'कोई सूचना नहीं';

  @override
  String get wageSummary => 'वेत सारांश';

  @override
  String get monthlyWageSummariesAppearHere => 'मासिक वेत सारांश यहां दिखाई देते हैं';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get marathi => 'मराठी';
}
