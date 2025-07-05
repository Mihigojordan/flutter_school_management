import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import './app/router.dart';
import '../providers/notification_provider.dart';
import '../providers/locale_provider.dart'; // your locale provider
import 'firebase_options.dart';
import 'package:school_project/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Kigali'));

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    logCurrentScreen('InitialScreen');
  }

  Future<void> logCurrentScreen(String screenName) async {
    await analytics.setCurrentScreen(screenName: screenName);
    debugPrint('Analytics: Current screen set to $screenName');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    router.routerDelegate.addListener(() {
      final currentRoute = router.routerDelegate.currentConfiguration;
      if (currentRoute != null) {
        logCurrentScreen(currentRoute.toString());
      }
    });

    ref.read(notificationServiceProvider);

   return MaterialApp.router(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primarySwatch: Colors.blue),
  routerConfig: router,
  locale: locale,
  supportedLocales: const [
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
  ],
  localeResolutionCallback: (locale, supportedLocales) {
  // Fallback to English for Material if 'rw' is not supported
  if (locale != null && ['en', 'fr'].contains(locale.languageCode)) {
    return locale;
  }
  if (locale?.languageCode == 'rw') {
    return const Locale('en');
  }
  return const Locale('en');
},

  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
);


  }
}
