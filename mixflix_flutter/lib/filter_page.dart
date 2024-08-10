import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'globals.dart';
import 'library.dart';
import 'methods.dart';
import 'theme.dart';

import 'wait_page.dart';
import 'tutorial.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ThemeColor.darkGray,
        body: Center(
          child: Stack(
            children: [
              Padding(
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
                      height: 70,
                    ),
                    Text(
                      'What do you want to watch?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: ThemeColor.offWhite,
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                          'Shows',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: ThemeColor.offWhite,
                          ),
                        ),
                        onPressed: () async {
                          host = true;
                          shows = true;
                          movies = false;
                          createSession(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WaitPage()),
                          );
                        },
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
                          'Movies',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: ThemeColor.offWhite,
                          ),
                        ),
                        onPressed: () async {
                          host = true;
                          shows = false;
                          movies = true;
                          createSession(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WaitPage()),
                          );
                        },
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
                          'Both',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: ThemeColor.offWhite,
                          ),
                        ),
                        onPressed: () async {
                          host = true;
                          shows = true;
                          movies = true;
                          createSession(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WaitPage()),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 100,
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
                          MaterialPageRoute(builder: (context) => WaitPage()),
                        );
                      },
                    ),
                  ),
                ),
              if (tutCompleted == false)
                Tutorial(
                  phase: 2,
                  bodyText: text2,
                  buttonText: buton2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
