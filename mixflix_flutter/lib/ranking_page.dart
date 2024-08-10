import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';

import 'globals.dart';
import 'library.dart';
import 'theme.dart';

import 'podium_page.dart';
import 'tutorial.dart';

List<String> items = [
  'Item 1',
  'Item 2',
  'Item 3',
  'Item 4',
  'Item 5',
];

List<DocumentReference> mutualLikesRefs = [];
List<YourTile> tiles = [];

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  bool isLoading = true;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    print("init");
    getMutualLikes();
  }

  Future<void> getMutualLikes() async {
    final document = await FirebaseFirestore.instance
        .collection('Sessions')
        .doc(sessionID.toString())
        .get();
    final List<dynamic> mutualLikes = document.data()?['MutualLikes'];
    mutualLikesRefs = mutualLikes.cast<DocumentReference>();

    tiles = await Future.wait(
      mutualLikesRefs.map(
        (ref) async {
          final docSnapshot = await ref.get();
          final doc = docSnapshot.data() as Map<String, dynamic>;
          final title = doc['Title'];
          final coverUrl = doc['Cover'];
          final duration = doc['Duration'];

          final genres = doc['Genres'];

          final documentReference = ref;

          await precacheImage(NetworkImage(coverUrl), context);

          print("precache");

          return YourTile(
            key: ValueKey(documentReference),
            cover: coverUrl,
            duration: duration,
            title: title,
            genre: "hi",
            genres: genres,
          );
        },
      ),
    );

    setState(() {
      print("false");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ThemeColor.darkGray,
          body: Center(
            child: CircularProgressIndicator(
              color: ThemeColor.indicatorColor,
            ),
          ),
        ),
      );
    } else {
      print("return");
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
                      //SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                'Ranking',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeColor.offWhite,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return RankingDialog();
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.help_outline,
                                      color: ThemeColor.handleGray),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 620,
                        child: ReorderableListView(
                          dragStartBehavior: DragStartBehavior.down,
                          physics: NeverScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final tile = tiles.removeAt(oldIndex);
                              tiles.insert(newIndex, tile);
                            });
                          },
                          children: List.generate(tiles.length, (index) {
                            return Padding(
                              key: ValueKey(tiles[index].key),
                              padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                              child: tiles[index],
                            );
                          }),
                          proxyDecorator: (widget, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              child: widget,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12),

                      Stack(
                        children: [
                          if (!_isSubmitted)
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
                                  'Done',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.offWhite,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isSubmitted =
                                        true; // Show loading indicator
                                  });

                                  final newOrder = tiles.map((tile) {
                                    final docRef = tile.key as ValueKey;
                                    final docId =
                                        docRef.value as DocumentReference;
                                    return docId;
                                  }).toList();

                                  // Update the session document with the new order
                                  final sessionDoc = FirebaseFirestore.instance
                                      .collection('Sessions')
                                      .doc(sessionID.toString());
                                  if (host == true) {
                                    await sessionDoc
                                        .update({'Ranking1': newOrder});
                                  }
                                  if (host == false || mobileDebug == true) {
                                    await sessionDoc
                                        .update({'Ranking2': newOrder});
                                  }
                                },
                              ),
                            ),
                          if (_isSubmitted) SizedBox(height: 50),
                          if (_isSubmitted)
                            CircularProgressIndicator(
                              color: ThemeColor.indicatorColor,
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
                            MaterialPageRoute(
                                builder: (context) => PodiumPage()),
                          );
                        },
                      ),
                    ),
                  ),
                LeaveSessionButton(),
                if (tutCompleted == false)
                  Tutorial(
                    phase: 5,
                    bodyText: text5,
                    buttonText: buton5,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
