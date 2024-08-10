import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';

import 'globals.dart';
import 'library.dart';
import 'methods.dart';
import 'theme.dart';

import 'ranking_page.dart';
import 'tutorial.dart';

class PodiumPage extends StatefulWidget {
  @override
  _PodiumPageState createState() => _PodiumPageState();
}

class _PodiumPageState extends State<PodiumPage> {
  bool isLoading = true;
  String coverURL1 = '';
  String coverURL2 = '';
  String coverURL3 = '';
  String coverURL4 = '';
  String coverURL5 = '';
  String title1 = '';
  String title2 = '';
  String title3 = '';
  String title4 = '';
  String title5 = '';

  CalcAverageRank() async {
    final sessionDocSnap = await FirebaseFirestore.instance
        .collection('Sessions')
        .doc(sessionID.toString())
        .get();

    final sessionDocRef = FirebaseFirestore.instance
        .collection('Sessions')
        .doc(sessionID.toString());

    final user1References =
        List<DocumentReference>.from(sessionDocSnap.data()!['Ranking1']);
    final user2References =
        List<DocumentReference>.from(sessionDocSnap.data()!['Ranking2']);

    List<double> averagedRankings = [];
    Map<DocumentReference, double> rankingMap = {};

    for (int i = 0; i < user1References.length; i++) {
      DocumentReference itemReference = user1References[i];

      List<int> user1Indexes = [];
      List<int> user2Indexes = [];

      for (int j = 0; j < user1References.length; j++) {
        if (user1References[j] == itemReference) {
          user1Indexes.add(j);
        }
        if (user2References[j] == itemReference) {
          user2Indexes.add(j);
        }
      }

      double sum = 0.0;
      for (int k = 0; k < user1Indexes.length; k++) {
        sum += (user1Indexes[k] + user2Indexes[k]) / 2.0;
      }

      double averageRanking = sum / user1Indexes.length;
      averagedRankings.add(averageRanking);
      rankingMap[itemReference] = averageRanking;
    }

    // Print order based of of user 1 rankings
    print(averagedRankings);

    List<DocumentReference> rankedReferences = rankingMap.keys.toList();
    rankedReferences.sort((a, b) => rankingMap[a]!.compareTo(rankingMap[b]!));

    await sessionDocRef.update({'Final_Ranking': rankedReferences});
  }

  void getAverageList() async {
    DocumentSnapshot mainDoc = await FirebaseFirestore.instance
        .collection('Sessions')
        .doc(sessionID.toString())
        .get();
    List<dynamic> otherDocRefs = mainDoc.get('Final_Ranking');
    DocumentReference otherDocRef0 = otherDocRefs[0];
    DocumentReference otherDocRef1 = otherDocRefs[1];
    DocumentReference otherDocRef2 = otherDocRefs[2];
    DocumentReference otherDocRef3 = otherDocRefs[3];
    DocumentReference otherDocRef4 = otherDocRefs[4];
    DocumentSnapshot otherDoc0 = await otherDocRef0.get();
    DocumentSnapshot otherDoc1 = await otherDocRef1.get();
    DocumentSnapshot otherDoc2 = await otherDocRef2.get();
    DocumentSnapshot otherDoc3 = await otherDocRef3.get();
    DocumentSnapshot otherDoc4 = await otherDocRef4.get();
    Map<String, dynamic> otherDocData0 =
        otherDoc0.data() as Map<String, dynamic>;
    Map<String, dynamic> otherDocData1 =
        otherDoc1.data() as Map<String, dynamic>;
    Map<String, dynamic> otherDocData2 =
        otherDoc2.data() as Map<String, dynamic>;
    Map<String, dynamic> otherDocData3 =
        otherDoc3.data() as Map<String, dynamic>;
    Map<String, dynamic> otherDocData4 =
        otherDoc4.data() as Map<String, dynamic>;

    setState(() {
      coverURL1 = otherDocData0["Cover"];
      coverURL2 = otherDocData1["Cover"];
      coverURL3 = otherDocData2["Cover"];
      coverURL4 = otherDocData3["Cover"];
      coverURL5 = otherDocData4["Cover"];
      title1 = otherDocData0["Title"];
      title2 = otherDocData1["Title"];
      title3 = otherDocData2["Title"];
      title4 = otherDocData3["Title"];
      title5 = otherDocData4["Title"];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Call your method here
    hello();
  }

  void hello() async {
    await CalcAverageRank();
    getAverageList();
  }

  void requestRating() {
    InAppReview.instance.openStoreListing(appStoreId: 'your_app_store_id');
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
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ThemeColor.darkGray,
          body: Center(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      height: 375,
                      width: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          coverURL1,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      title1,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.offWhite,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            PodiumTile(
                                cover: coverURL2, title: title2, number: 2),
                            PodiumTile(
                                cover: coverURL3, title: title3, number: 3),
                            PodiumTile(
                                cover: coverURL4, title: title4, number: 4),
                            PodiumTile(
                                cover: coverURL5, title: title5, number: 5),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
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
                              'Exit',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: ThemeColor.offWhite,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                tutCompleted = true;
                              });
                              Home(context);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                BetaVersionText(),
                if (debug == true)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
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
                                  builder: (context) => RankingPage()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                if (tutCompleted == false)
                  Tutorial(
                    phase: 6,
                    bodyText: text6,
                    buttonText: buton6,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
