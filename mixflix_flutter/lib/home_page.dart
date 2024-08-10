import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netflix_tinder_flutter/globals.dart';
import 'package:netflix_tinder_flutter/tutorial.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_share/flutter_share.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'library.dart';
import 'methods.dart';
import 'theme.dart';

import 'tinder_page.dart';
import 'filter_page.dart';
import 'help_page.dart';

final textController = TextEditingController();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    if (versionCheckEnabled == true) {
      FetchLatestVersion(context);
    } else {
      versionUpToDate = true;
    }
    fetchResources();
    initCheat();
  }

  void initCheat() async {
    print("yo0");
    await fetchPosters(context);
    print("yo1");
    doneLoadingHome();
  }

  void JoinSession() async {
    String inputText = textController.text;
    if (inputText == "69") {
      mobileDebug = true;
      debugButtonVis = true;
      textController.clear();
    } else {
      if (versionCheckEnabled == true) {
        FetchLatestVersion(context);
      }
      if (versionUpToDate == true) {
        // Get the input text from the user
        String inputText = textController.text;
        if (inputText.length >= 5) {
          // Query the Firestore database to check if a document with the same name exists
          var docRef = await FirebaseFirestore.instance
              .collection("Sessions")
              .doc(inputText);
          var snapshot = await docRef.get();

          // If a document exists, navigate to the "hello" page
          if (snapshot.exists) {
            var data = snapshot.data();
            if (data?['Joined'] == false) {
              await docRef.update({"Joined": true});
              host = false;
              shows = data?['Shows'];
              movies = data?['Movies'];
              sessionID = int.parse(inputText);
              createListener(context);
              textController.clear();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TinderPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Session has already been joined")),
              );
            }
          } else {
            // Show a warning message using a SnackBar widget
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Session does not exist")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Code must be 5 digits")),
          );
        }
      }
    }
  }

  void shareMessageIOS() async {
    try {
      await FlutterShare.share(
        title: 'MixFlix',
        text: shareMessage, // The message to be shared
      );
    } catch (e) {
      print('Error sharing message: $e');
    }
  }

  void endTutorial() async {
    setState(() {
      tutCompleted = true;
      tutPhase = -1;
    });
  }

  bool isLoading = true;

  void doneLoadingHome() async {
    setState(() {
      print("gay");
      isLoading = false;
    });
    await Future.delayed(Duration(milliseconds: 30));
    setState(() {
      opacity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return Center(
                child: CircularProgressIndicator(
                  color: ThemeColor.indicatorColor,
                ),
              );
    } else {
      return WillPopScope(
        onWillPop: () async => false,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: AnimatedOpacity(
            // Wrap the entire Scaffold widget in AnimatedOpacity
            opacity: opacity, // Use the opacity variable as the value
            duration: Duration(
                milliseconds: 300), // Set the duration of the fade animation
            child: Scaffold(
              backgroundColor: ThemeColor.darkGray,
              body: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Stack(
                        children: [
                          ImageCarousel(),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 330),
                                Container(
                                  // was max (400)
                                  width: 330,
                                  height: 158,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors
                                          .transparent, // Set the desired outline color
                                      width:
                                          2.0, // Set the desired outline width
                                    ),
                                  ),
                                  child: Image.asset(
                                    LogoPath.logoPath,
                                  ),
                                ),
                                SizedBox(
                                  height: 0,
                                ),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ThemeColor.lightGray,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Host',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        color: ThemeColor.offWhite,
                                      ),
                                    ),
                                    onPressed: () async {
                                      await FetchLatestVersion(context);
                                      if (versionUpToDate == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FilterPage()),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: ThemeColor.lightGray,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextField(
                                    style: GoogleFonts.montserrat(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      color: ThemeColor.textGray,
                                    ),
                                    controller: textController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLength: 5,
                                    textAlign: TextAlign.center,
                                    cursorColor: ThemeColor.offWhite,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 12.5),
                                      hintText: 'Enter code',
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        //fontStyle: FontStyle.italic,
                                        color: ThemeColor.textGray,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ThemeColor.lightGray,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Join',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        color: ThemeColor.offWhite,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {});
                                      JoinSession();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  // child: Align(
                                  //   alignment: Alignment.bottomCenter,
                                  //   child: Padding(
                                  //     padding: EdgeInsets.all(12.0),
                                  //     child: Text(
                                  //       'Download Link',
                                  //       style: GoogleFonts.montserrat(
                                  //         fontSize: 20,
                                  //         fontWeight: FontWeight.w400,
                                  //         color: ThemeColor.offWhite,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 140,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ThemeColor.lightGray,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Share',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: ThemeColor.offWhite,
                                          ),
                                        ),
                                        onPressed: () {
                                          // if (Platform.isAndroid) {
                                          //   Clipboard.setData(
                                          //       ClipboardData(text: shareMessage));
                                          //   ScaffoldMessenger.of(context)
                                          //       .showSnackBar(
                                          //     SnackBar(
                                          //       content: Text(
                                          //           'Copied link to clipboard'),
                                          //       duration: Duration(seconds: 2),
                                          //     ),
                                          //   );
                                          // }
                                          // else {
                                          //   shareMessageIOS();
                                          // }
                                          shareMessageIOS();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          BetaVersionText(),
                          if (debug == true)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: ElevatedButton(
                                  child: Text(
                                    'next',
                                  ),
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => FilterPage()),
                                    // );

                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => SwipeTest5()),
                                    // );
                                  },
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 52,
                            right: 30,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HelpPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.help_outline,
                                    color: ThemeColor.handleGray),
                              ),
                            ),
                          ),
                          if (mobileDebug == true && debugButtonVis == true)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: ElevatedButton(
                                  child: Text(
                                    'Debug',
                                  ),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'tutorial_completed', false);
                                  },
                                ),
                              ),
                            ),
                          if (tutCompleted == false)
                            Tutorial(
                              phase: 1,
                              bodyText: text1,
                              buttonText: buton1,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
