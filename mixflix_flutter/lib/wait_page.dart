import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';


import 'globals.dart';
import 'library.dart';
import 'methods.dart';
import 'theme.dart';

import 'tinder_page.dart';
import 'tutorial.dart';

List<DocumentReference> seenDocs = [];

DocumentReference randomPoolRef =
    db.collection("Sessions").doc(sessionID.toString());

DocumentReference? randomRefFromPool;

String coverURL = "";
String yo = "";
String description = "";
String duration = "";
String rating = "";
String year = "";

class WaitPage extends StatefulWidget {
  const WaitPage({super.key});
  @override
  _WaitPageState createState() => _WaitPageState();
}

class _WaitPageState extends State<WaitPage> {
  void shareCode() async {
    try {
      await FlutterShare.share(
        title: 'MixFlix',
        text: sessionID.toString(), // The message to be shared
      );
    } catch (e) {
      print('Error sharing message: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ThemeColor.darkGray,
        body: Center(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Container(
                        width: 300,
                        height: 168,
                        child: Image.asset(
                          LogoPath.logoPath,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      SizedBox(
                        width: 300,
                        child: Text(
                          "Waiting for other person to join",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: ThemeColor.offWhite,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      const CircularProgressIndicator(
                        color: ThemeColor.indicatorColor,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Code",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: ThemeColor.offWhite,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 50,),
                          Text(
                            sessionID.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              color: ThemeColor.offWhite,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: IconButton(
                              icon: Icon(CupertinoIcons.share),
                              color: ThemeColor
                                  .textGray, // Change the color to your desired color
                              onPressed: () {
                                shareCode();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 110,
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: ThemeColor.offWhite,
                                ),
                              ),
                              onPressed: () {
                                Home(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TinderPage()),
                        );
                      },
                    ),
                  ),
                ),
              if (debug == false &&
                  mobileDebug == true &&
                  debugButtonVis == true)
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
                      },
                    ),
                  ),
                ),
              if (tutCompleted == false)
                Tutorial(
                  phase: 3,
                  bodyText: text3,
                  buttonText: buton3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
