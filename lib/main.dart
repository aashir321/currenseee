import 'package:currensee/pages/currency_converter_screen.dart';
import 'package:currensee/pages/currency_detail_screen.dart';
import 'package:currensee/pages/currency_list_screen.dart';
import 'package:currensee/pages/news_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase app has already been initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CurrenSee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/home':
            // Assuming HomePage requires a displayName parameter
            final args = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => HomePage(displayName: args!),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterPage());
          case '/currency_converter':
            return MaterialPageRoute(builder: (context) => const CurrencyConverterScreen());
          case '/currency_list':
            return MaterialPageRoute(builder: (context) => const CurrencyListScreen());
          case '/currency_news':
            return MaterialPageRoute(builder: (context) => const NewsScreen());
          case '/splash_page':
            return MaterialPageRoute(builder: (context) => const SplashScreen());
          default:
            return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
      },
    );
  }
}
