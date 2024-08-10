import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'globals.dart';
import 'library.dart';
import 'methods.dart';
import 'theme.dart';

import 'wait_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  final double spacing = 20;

  final String text1 =
      "User 1 presses “Host” to start a session and then selects whether they would like to be shown Movies, Shows, or Both.";
  final String text2 =
      "User 2 joins the session by typing in the code shown to User 1 and tapping “Join”";
  final String text3 =
      "Both users will then be shown a recommendation to which they can react with “sure” if they are in the mood to watch that particular title, or “nah” if they aren’t. Users can also swipe right or left instead of pressing the buttons.";
  final String text4 =
      "Once 5 titles have been reacted to with “Sure” by both users, they will be taken to the ranking page.";
  final String text5 =
      "Both users then drag the cards by the handle on the right in the order that they’d most prefer to watch them and then press done.";
  final String text6 =
      "Once both users have pressed done, the average ranking of the titles between the two users will be calculated.";
  final String text7 =
      "The final page shows the title with the highest average ranking followed by the other 4 titles in order of average ranking.";

  final String aboutText = '''
  1. User 1 presses “Host” to start a session
      and then selects whether they would like
      to be shown Movies, Shows, or Both.

  2. User 2 joins the session by typing in the
      code shown to User 1 and tapping “Join”.

  3. Both users will then be shown a
      recommendation to which they can
      react with “sure” if they are in the mood
      to watch that particular title, or “nah” if
      they aren’t. Users can also swipe right or
      left instead of pressing the buttons.

  4. Once 5 titles have been reacted to with
      “Sure” by both users, they will be taken
      to the ranking page.

  5. Both users then drag the cards by the
      handle on the right in the order that
      they’d most prefer to watch them and
      then press done.

  6. Once both users have pressed done, the
      average ranking of the titles between the
      two users will be calculated

  7. The final page shows the title with the
      highest average ranking followed by the
      other 4 titles in order of average ranking
  ''';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: ThemeColor.darkGray,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          elevation: 0.0,
          backgroundColor: ThemeColor.darkGray,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 0),
                      // Container(
                      //   width: 300,
                      //   child: Image.asset(
                      //     'assets/placeholder_logo.png',
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 70,
                      // ),
                      Text(
                        'Getting Started',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.offWhite,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      HelpText(number: "1. ", text: text1),
                      SizedBox(height: spacing),
                      HelpText(number: "2. ", text: text2),
                      SizedBox(height: spacing),
                      HelpText(number: "3. ", text: text3),
                      SizedBox(height: spacing),
                      HelpText(number: "4. ", text: text4),
                      SizedBox(height: spacing),
                      HelpText(number: "5. ", text: text5),
                      SizedBox(height: spacing),
                      HelpText(number: "6. ", text: text6),
                      SizedBox(height: spacing),
                      HelpText(number: "7. ", text: text7),
                      SizedBox(
                        height: 30,
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
                                'Back',
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
                      SizedBox(
                        height: 36,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
