import './common.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';
import './screens/coupons_screen.dart';
import './data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void changeLanguage(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeDark = ThemeData(
      brightness: Brightness.dark,
      focusColor: Colors.red,
      primaryColor: Colors.red,
      accentColor: Colors.red,
      buttonColor: Colors.white,
      appBarTheme: AppBarTheme(
        textTheme: TextTheme(),
        color: Colors.grey[800],
      ),
      dialogBackgroundColor: Colors.grey[900],
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: Colors.red)),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(primary: Colors.grey[300]),
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Data(),
        )
      ],
      child: MaterialApp(
        locale: _locale,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('ru', ''),
          const Locale('uk', ''),
        ],
        debugShowCheckedModeBanner: false,
        title: 'farstep',
        theme: themeDark,
        home: FirebaseAuth.instance.currentUser != null
            ? Data().checkIsOwner(context)
                ? FutureBuilder(
                    future: Data().fetchTypes(),
                    builder: (context, snapshot) {
                      Data().fetchLocaleIndex(context);
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Center(child: CircularProgressIndicator()));
                      else
                        return CouponsScreen();
                    })
                : Center(
                    child: AlertDialog(
                      content:
                          Text(AppLocalizations.of(context).error_go_support),
                    ),
                  )
            : AuthScreen(),
      ),
    );
  }
}
