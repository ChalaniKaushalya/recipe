import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:recipeapplication/services/locale_provider.dart';
import 'stores/user-store.dart';
import 'screens/start_page.dart';
import 'screens/settingspage.dart';
import 'screens/view_profile_page.dart';
import 'screens/favorite_list_page.dart';
import 'screens/login_page.dart';
import 'screens/contact_us_page.dart';
import 'screens/splash_screen.dart';
import 'screens/register_page.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await testFirebaseConnection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserStore()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const RecipeMateApp(),
    ),
  );
}

Future<void> testFirebaseConnection() async {
  try {
    var snapshot = await FirebaseFirestore.instance.collection('test').get();
    if (snapshot.docs.isNotEmpty) {
      debugPrint('Connected to Firebase and data is available!');
    } else {
      debugPrint('Connected to Firebase but no data found.');
    }
  } catch (e) {
    debugPrint('Error connecting to Firebase: $e');
  }
}

class RecipeMateApp extends StatelessWidget {
  const RecipeMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'Recipe Mate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      initialRoute: '/splash',
      locale: localeProvider.locale,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/':
        return MaterialPageRoute(builder: (_) => StartPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsPage());
      case '/viewProfile':
        if (settings.arguments is Map<String, dynamic>) {
          return MaterialPageRoute(builder: (_) => ViewProfilePage());
        }
        return _errorRoute();
      case '/favoriteList':
        return MaterialPageRoute(builder: (_) => FavoriteListPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/contactUs':
        return MaterialPageRoute(builder: (_) => ContactUsPage());
      default:
        return _errorRoute();
    }
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
          body: Center(child: Text(AppLocalizations.of(context)!.errorPage)),
        );
      },
    );
  }
}
