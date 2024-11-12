import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foodservice/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foodservice/home.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate, // Ensure this is added
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: Localizations.localeOf(context).languageCode == 'fa'
              ? TextDirection.ltr
              : TextDirection.ltr,
          child: child!,
        );
      },
      home: const _MyApp(),
    );
  }
}

class _MyApp extends StatefulWidget {
  const _MyApp();
  @override
  __MyApp createState() => __MyApp();
}

class __MyApp extends State<_MyApp> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: homePage());
  }
}
