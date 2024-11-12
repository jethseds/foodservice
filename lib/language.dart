import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foodservice/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class languagePage extends StatefulWidget {
  const languagePage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _languagePageState createState() => _languagePageState();
}

// ignore: camel_case_types
class _languagePageState extends State<languagePage> {
  Locale _locale = const Locale('en'); // Default locale

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: Localizations.localeOf(context).languageCode == 'zh' ||
                  Localizations.localeOf(context).languageCode == 'ja' ||
                  Localizations.localeOf(context).languageCode == 'id'
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: child!,
        );
      },
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 100,
                    child: Row(
                      children: [
                        Builder(builder: (context) {
                          final localizations = AppLocalizations.of(context)!;
                          return Text(
                            localizations.label1,
                            style: const TextStyle(fontSize: 20),
                          );
                        }),
                        Expanded(
                            child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: DropdownButton<String>(
                            value: _locale.languageCode == 'en'
                                ? 'English'
                                : _locale.languageCode == 'zh'
                                    ? 'Chinese'
                                    : _locale.languageCode == 'ja'
                                        ? 'Japanese'
                                        : _locale.languageCode == 'id'
                                            ? 'Indonesian'
                                            : 'en', // Default or fallback value
                            dropdownColor: Colors.white,
                            icon: const Icon(
                              Icons.language,
                              color: Colors.black,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _changeLanguage(newValue = newValue == 'English'
                                    ? 'en'
                                    : newValue == 'Chinese'
                                        ? 'zh'
                                        : newValue == 'Japanese'
                                            ? 'ja'
                                            : newValue == 'Indonesian'
                                                ? 'id'
                                                : 'en');
                              }
                            },
                            items: [
                              'English',
                              'Chinese',
                              'Japanese',
                              'Indonesian'
                            ].map<DropdownMenuItem<String>>((String language) {
                              return DropdownMenuItem<String>(
                                value: language,
                                child: Text(language),
                              );
                            }).toList(),
                          ),
                        ))
                      ],
                    )),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
