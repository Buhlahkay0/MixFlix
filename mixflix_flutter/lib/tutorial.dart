import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'theme.dart';

bool tutCompleted = false;
// int tutPhase = 0;

// bool modalVis = true;

int animDur = 600;
int modalHeight = 400;
int modalWidth = 300;

double shadeOp = 0;
bool modalVis = true;
int tutPhase = 0;

double firstModalPos = 1266;
double modalPos = 1266;

String text1 =
    "Great! Let’s get started.\n\n\nFirst, create a session by pressing “Host” on the homescreen.";
String text2 =
    "Next, choose whether you’d like to see movies, tv shows, or both.";
String text3 =
    "Here is where you would share your code with someone to join your session, but since it’s just us, we’ll continue to the next part.";
String text4 =
    "Great! You’ve officially started your first session.\n\nTo begin, swipe right if the recommendation piques your interest, or left if it’s not your cup of tea.";
String text5 =
    "After you and your session-mate have matched on 5 recommendations, You’ll be taken to the this page.\n\nNow, order your 5 matches in order of most to least interesting";
String text6 =
    "And that’s it!\n\nMixFlix automatically calculates which recommendation you and your session-mate like the most.\n\nNow go enjoy some cinema!  ";

String buton1 = "Okay";
String buton2 = "Okay";
String buton3 = "Okay";
String buton4 = "Okay";
String buton5 = "Okay";
String buton6 = "Okay";

class TutorialModal extends StatefulWidget {
  final int phase;
  final String bodyText;
  final String buttonText;

  final VoidCallback dismissMethod;

  TutorialModal({
    required this.phase,
    required this.bodyText,
    required this.buttonText,
    required this.dismissMethod,
  });

  @override
  _TutorialModalState createState() => _TutorialModalState();
}

class _TutorialModalState extends State<TutorialModal> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: ThemeColor.darkGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      widget.bodyText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: ThemeColor.offWhite,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  height: 44,
                  width: 260,
                  child: ElevatedButton(
                    onPressed: () async {
                      print("normal Modal: main button");

                      widget.dismissMethod();

                      if (tutPhase == 3) {
                        await Future.delayed(Duration(milliseconds: 2000));
                        mobileDebug = true;

                        var docRef = await FirebaseFirestore.instance
                            .collection("Sessions")
                            .doc(sessionID.toString());
                        var snapshot = await docRef.get();

                        // If a document exists, navigate to the "hello" page
                        if (snapshot.exists) {
                          var data = snapshot.data();
                          if (data?['Joined'] == false) {
                            await docRef.update({"Joined": true});
                          }
                        }
                      }

                      if (tutPhase == 6) {
                        setState(() {
                          tutCompleted = true;
                          tutPhase = -1;
                          mobileDebug = false;
                        });

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('tutorial_completed', true);
                      }

                      tutPhase = widget.phase + 1;
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: ThemeColor.lightGray,
                    ),
                    child: Text(
                      widget.buttonText,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ThemeColor.offWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirstTutorialModal extends StatefulWidget {
  final VoidCallback startTutMethod;
  final VoidCallback skipTutMethod;

  FirstTutorialModal({
    required this.startTutMethod,
    required this.skipTutMethod,
  });

  @override
  _FirstTutorialModalState createState() => _FirstTutorialModalState();
}

class _FirstTutorialModalState extends State<FirstTutorialModal> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: ThemeColor.darkGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: ThemeColor.offWhite,
                    ),
                  ),
                  Container(
                      width: 200,
                      height: 70,
                      child: Image.asset(LogoPath.logoPath)),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Get a 2 minute crash course of MixFlix by pressing “Give me a tour” or press “I’ll pass” if you’ve already used the app",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ThemeColor.offWhite,
                      ),
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    height: 44,
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () {
                        print("First Modal: tutorial button");
                        widget.startTutMethod();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: ThemeColor.lightGray,
                      ),
                      child: Text(
                        "Give me a tour",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ThemeColor.offWhite,
                        ),
                      ),
                    ),
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: 25,
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () async {
                        print("first modal: tutorial skipped");
                        widget.skipTutMethod();

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('tutorial_completed', true);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        "I'll Pass",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ThemeColor.textGray,
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// tutorial screen
class Tutorial extends StatefulWidget {
  final int phase;
  final String bodyText;
  final String buttonText;

  const Tutorial({
    Key? key,
    required this.phase,
    required this.bodyText,
    required this.buttonText,
  }) : super(key: key);

  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  @override
  void initState() {
    super.initState();

    enableShade();
    if (tutPhase == 0) {
      enableFirstModal();
    } else {
      enableModal();
    }
  }

  void enableShade() async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      modalVis = true;
      shadeOp = 0;
    });
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      shadeOp = 0.8;
    });
  }

  void enableFirstModal() async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      firstModalPos =
          (MediaQuery.of(context).size.height / 2) - (modalHeight / 2);
    });
  }

  void startTutorial() async {
    tutPhase = 1;

    setState(() {
      // off screen
      firstModalPos = 1266;
    });

    await Future.delayed(Duration(milliseconds: animDur));

    setState(() {
      // visable pos on screen
      modalPos = (MediaQuery.of(context).size.height / 2) - (modalHeight / 2);
    });
  }

  void skipTutorial() async {
    setState(() {
      // off screen
      firstModalPos = 1266;
      shadeOp = 0;
      tutCompleted = true;
      modalVis = false;
    });
  }

  void dismissModal() async {
    setState(() {
      // off screen
      modalPos = 1266;
      shadeOp = 0;
    });

    await Future.delayed(Duration(milliseconds: animDur));

    setState(() {
      modalVis = false;
    });
  }

  void enableModal() async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      // off screen
      modalPos = (MediaQuery.of(context).size.height / 2) - (modalHeight / 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (modalVis == true)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: animDur),
              opacity: shadeOp,
              child: Container(
                color: Colors.black,
              ),
            ),
          ),
        // first modal
        AnimatedPositioned(
          duration: Duration(milliseconds: animDur),
          curve: Curves.easeInOut,
          left: (MediaQuery.of(context).size.width / 2) - (modalWidth / 2),
          top: firstModalPos,
          child: FirstTutorialModal(
            startTutMethod: startTutorial,
            skipTutMethod: skipTutorial,
          ),
        ),
        // normal modal
        AnimatedPositioned(
          duration: Duration(milliseconds: animDur),
          curve: Curves.easeInOut,
          left: (MediaQuery.of(context).size.width / 2) - (modalWidth / 2),
          top: modalPos,
          child: TutorialModal(
            phase: widget.phase,
            bodyText: widget.bodyText,
            buttonText: widget.buttonText,
            dismissMethod: dismissModal,
          ),
        ),
      ],
    );
  }
}
