/// Lightweight, in-app translation lookup for Beadly's UI chrome (not the
/// user's own chant names, which are free text). Supports English, Bengali,
/// Hindi, and Arabic.
class BeadlyStrings {
  final String languageCode;
  const BeadlyStrings(this.languageCode);

  static const _table = <String, Map<String, String>>{
    'appName': {
      'en': 'Beadly',
      'bn': 'বিডলি',
      'hi': 'बीडली',
      'ar': 'بيدلي',
    },
    'chooseTradition': {
      'en': 'Choose your tradition',
      'bn': 'আপনার ঐতিহ্য বেছে নিন',
      'hi': 'अपनी परंपरा चुनें',
      'ar': 'اختر تقليدك',
    },
    'chooseTraditionSubtitle': {
      'en': 'You can change this anytime in Settings.',
      'bn': 'আপনি এটি সেটিংসে যেকোনো সময় পরিবর্তন করতে পারেন।',
      'hi': 'आप इसे कभी भी सेटिंग्स में बदल सकते हैं।',
      'ar': 'يمكنك تغيير هذا في أي وقت من الإعدادات.',
    },
    'continue': {'en': 'Continue', 'bn': 'চালিয়ে যান', 'hi': 'जारी रखें', 'ar': 'متابعة'},
    'today': {'en': 'Today', 'bn': 'আজ', 'hi': 'आज', 'ar': 'اليوم'},
    'thisWeek': {'en': 'This Week', 'bn': 'এই সপ্তাহ', 'hi': 'इस सप्ताह', 'ar': 'هذا الأسبوع'},
    'rounds': {'en': 'rounds', 'bn': 'রাউন্ড', 'hi': 'चक्र', 'ar': 'جولات'},
    'counter': {'en': 'Counter', 'bn': 'কাউন্টার', 'hi': 'काउंटर', 'ar': 'العداد'},
    'history': {'en': 'History', 'bn': 'ইতিহাস', 'hi': 'इतिहास', 'ar': 'السجل'},
    'settings': {'en': 'Settings', 'bn': 'সেটিংস', 'hi': 'सेटिंग्स', 'ar': 'الإعدادات'},
    'weekly': {'en': 'Weekly', 'bn': 'সাপ্তাহিক', 'hi': 'साप्ताहिक', 'ar': 'أسبوعي'},
    'monthly': {'en': 'Monthly', 'bn': 'মাসিক', 'hi': 'मासिक', 'ar': 'شهري'},
    'totalThisWeek': {
      'en': 'Total rounds this week',
      'bn': 'এই সপ্তাহে মোট রাউন্ড',
      'hi': 'इस सप्ताह कुल चक्र',
      'ar': 'إجمالي الجولات هذا الأسبوع',
    },
    'totalThisMonth': {
      'en': 'Total rounds this month',
      'bn': 'এই মাসে মোট রাউন্ড',
      'hi': 'इस महीने कुल चक्र',
      'ar': 'إجمالي الجولات هذا الشهر',
    },
    'currentStreak': {
      'en': 'Current streak (days)',
      'bn': 'বর্তমান ধারা (দিন)',
      'hi': 'वर्तमान लकीर (दिन)',
      'ar': 'التتابع الحالي (أيام)',
    },
    'bestDay': {'en': 'Best day', 'bn': 'সেরা দিন', 'hi': 'सर्वश्रेष्ठ दिन', 'ar': 'أفضل يوم'},
    'tradition': {'en': 'Tradition', 'bn': 'ঐতিহ্য', 'hi': 'परंपरा', 'ar': 'التقليد'},
    'targetCount': {'en': 'Target count', 'bn': 'লক্ষ্য সংখ্যা', 'hi': 'लक्ष्य गणना', 'ar': 'العدد المستهدف'},
    'sound': {'en': 'Sound on completion', 'bn': 'সমাপ্তিতে শব্দ', 'hi': 'पूर्ण होने पर ध्वनि', 'ar': 'الصوت عند الإكمال'},
    'vibration': {'en': 'Vibration on completion', 'bn': 'সমাপ্তিতে কম্পন', 'hi': 'पूर्ण होने पर कंपन', 'ar': 'الاهتزاز عند الإكمال'},
    'darkMode': {'en': 'Dark mode', 'bn': 'ডার্ক মোড', 'hi': 'डार्क मोड', 'ar': 'الوضع الداكن'},
    'language': {'en': 'Language', 'bn': 'ভাষা', 'hi': 'भाषा', 'ar': 'اللغة'},
    'comingSoon': {'en': 'Coming soon', 'bn': 'শীঘ্রই আসছে', 'hi': 'जल्द आ रहा है', 'ar': 'قريباً'},
    'premium': {'en': 'Premium', 'bn': 'প্রিমিয়াম', 'hi': 'प्रीमियम', 'ar': 'مميز'},
    'cloudSync': {'en': 'Cloud sync', 'bn': 'ক্লাউড সিঙ্ক', 'hi': 'क्लाउड सिंक', 'ar': 'مزامنة سحابية'},
    'reset': {'en': 'Reset count?', 'bn': 'গণনা রিসেট করবেন?', 'hi': 'गिनती रीसेट करें?', 'ar': 'إعادة تعيين العدد؟'},
    'resetBody': {
      'en': 'This will set your current count back to 0. This round will not be logged.',
      'bn': 'এটি আপনার বর্তমান গণনা ০ এ ফিরিয়ে দেবে। এই রাউন্ডটি লগ করা হবে না।',
      'hi': 'यह आपकी वर्तमान गिनती को 0 पर वापस सेट कर देगा। यह चक्र लॉग नहीं होगा।',
      'ar': 'سيؤدي هذا إلى إعادة تعيين عدك الحالي إلى 0. لن يتم تسجيل هذه الجولة.',
    },
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল', 'hi': 'रद्द करें', 'ar': 'إلغاء'},
    'renameChant': {'en': 'Rename chant', 'bn': 'জপ পুনঃনামকরণ', 'hi': 'जाप का नाम बदलें', 'ar': 'إعادة تسمية الذكر'},
    'save': {'en': 'Save', 'bn': 'সংরক্ষণ', 'hi': 'सहेजें', 'ar': 'حفظ'},
    'changeTradition': {'en': 'Change tradition', 'bn': 'ঐতিহ্য পরিবর্তন করুন', 'hi': 'परंपरा बदलें', 'ar': 'تغيير التقليد'},
    'screenOffCounting': {
      'en': 'Count with screen off',
      'bn': 'স্ক্রিন অফ অবস্থায় গণনা',
      'hi': 'स्क्रीन ऑफ रहने पर गिनती',
      'ar': 'العد والشاشة مطفأة',
    },
    'screenOffCountingDesc': {
      'en': 'Volume buttons keep counting in the background. Shows a persistent notification and uses more battery.',
      'bn': 'ভলিউম বাটন ব্যাকগ্রাউন্ডেও গণনা করতে থাকবে। এর জন্য একটি স্থায়ী notification দেখাবে এবং ব্যাটারি একটু বেশি খরচ হবে।',
      'hi': 'वॉल्यूम बटन बैकग्राउंड में भी गिनती करते रहेंगे। इसके लिए एक स्थायी notification दिखेगा और बैटरी थोड़ी ज़्यादा खर्च होगी।',
      'ar': 'ستستمر أزرار الصوت في العد في الخلفية. يظهر إشعار دائم ويستهلك بطارية أكثر.',
    },
    'notificationPermissionDenied': {
      'en': 'Notification permission was denied, so this could not be turned on.',
      'bn': 'Notification permission দেওয়া হয়নি, তাই এটি চালু করা যায়নি।',
      'hi': 'Notification permission नहीं मिली, इसलिए इसे चालू नहीं किया जा सका।',
      'ar': 'تم رفض إذن الإشعارات، لذا تعذّر تفعيل هذا.',
    },
  };

  String t(String key) {
    final entry = _table[key];
    if (entry == null) return key;
    return entry[languageCode] ?? entry['en']!;
  }

  static const supportedLanguages = <String, String>{
    'en': 'English',
    'bn': 'বাংলা (Bengali)',
    'hi': 'हिन्दी (Hindi)',
    'ar': 'العربية (Arabic)',
  };
}
