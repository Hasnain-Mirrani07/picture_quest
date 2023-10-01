import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'feed_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = FirebaseAuth.instance.currentUser != null
        ? true
        : false; // check user logged in or not
    if (isLoggedIn) {
      return MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.heeboTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
          useMaterial3: true,
        ),
        home: FeedView(),
      );
    }
    return MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.heeboTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
          useMaterial3: true,
        ),
        home: SignUpScreen());
  }
}
