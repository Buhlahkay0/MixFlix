import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'tutorial.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Android nav bar color
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: ThemeColor.darkGray,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: ThemeColor.darkGray,
        ),
        title: 'MixFlix',
        home: FutureBuilder<bool>(
          future: checkTutorialCompleted(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the data, you can show a loading indicator.
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.transparent,
                ),
              );
            } else {
              bool tutorialCompleted = snapshot.data ?? false;
              if (tutorialCompleted) {
                // Tutorial is completed, show the main app content.
                tutCompleted = true;
                return HomePage();
              } else {
                // Tutorial is not completed, print "Tutorial needed."
                print("Tutorial not complete");
                return HomePage();
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool> checkTutorialCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_completed') ?? false;
  }
}
