import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:async';
import "dart:math" as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';

import 'globals.dart';
import 'library.dart';
import 'methods.dart';
import 'theme.dart';

import 'ranking_page.dart';
import 'tutorial.dart';

List<DocumentReference> seenDocs = [];

late Map<String, dynamic>? fromPoolData;
late Map<String, dynamic>? currentFromPoolData;

ImageProvider cachedImage = NetworkImage(
    'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg');
ImageProvider currentImage = NetworkImage(
    'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg');

bool _showImage = true;

double pos1 = 0;

final double _topSpacing = 72;

// container size / 2

// milliseconds
double _finDur = 400;
int rDur = 300;
int dur1 = 0;
int dur2 = 0;
int dur3 = 0;

int currentCard = 2;

ImageProvider currentImage1 = NetworkImage(
    'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg');

ImageProvider currentImage2 = NetworkImage(
    'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/9NXAlFEE7WDssbXSMgdacsUD58Y.jpg');

ImageProvider currentImage3 = NetworkImage(
    'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/liLN69YgoovHVgmlHJ876PKi5Yi.jpg');

final double _offset = 250 / 2;

final int swipeThreshold = 50;

double _yOffset = 0.0;
double _dragVelocity = 0.0;
double dur = 0;
double ogPos = 0;

double img1Pos = 0;
double img2Pos = 0;
double img3Pos = 0;

bool img1Vis = true;
bool img2Vis = true;
bool img3Vis = true;

double position1 = 0;
double position2 = 0;
double position3 = 0;

class TinderPage extends StatefulWidget {
  @override
  _TinderPageState createState() => _TinderPageState();
}

class _TinderPageState extends State<TinderPage> {
  bool isLoading = true;

  DocumentReference randomPoolRef =
      db.collection("Sessions").doc(sessionID.toString());

  DocumentReference? randomRefFromPool;

  DocumentReference? currentRandomRefFromPool;

  String coverURL = "";
  String yo = "";
  String description = "";
  String duration = "";
  String rating = "";
  String year = "";
  String genres = "";

  bool _buttonEnabled = true;
  bool _delayActive = false;
  bool _methodsRunning = false;

  // milliseconds
  final int _delay = 500;

  GetDocFromPool() async {
    final CollectionReference collection = db.collection(collectionName);
    QuerySnapshot snapshot;
    snapshot = await collection.get();

    final DocumentReference sessionDocRef =
        db.collection('Sessions').doc(sessionID.toString());

    DocumentSnapshot sessionSnap = await sessionDocRef.get();
    final Map<String, dynamic>? data =
        sessionSnap.data() as Map<String, dynamic>?;
    final List<dynamic>? myArray = data?['Pool'] as List<dynamic>?;
    numberOfItems = myArray?.length ?? 0;
    print('The number of items in "Pool" is ${numberOfItems + 1}');

    int loopCounter = 0;

    if (seenDocs.length < numberOfItems) {
      int randomIndex;
      do {
        loopCounter++;
        if (loopCounter > 1000) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Something went wrong :( please restart the app")),
          );
          print("Looped 1000 times and couldnt find document");
          break;
        }

        randomIndex =
            numberOfItems > 0 ? math.Random().nextInt(numberOfItems) : 0;
        randomRefFromPool = myArray?[randomIndex] as DocumentReference?;
      } while (seenDocs.contains(randomRefFromPool) == true);

      final DocumentSnapshot randomSnapFromPool =
          await randomRefFromPool!.get();

      seenDocs.add(randomRefFromPool!);
      print("Added Ref from Pool. length = " + seenDocs.length.toString());

      fromPoolData = randomSnapFromPool.data() as Map<String, dynamic>?;

      cachedImage = NetworkImage(fromPoolData?["Cover"]);
      precacheImage(cachedImage, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "You guys are picky asl. All content that fits your criteria has been shown")),
      );
    }
  }

  setDocState() {
    setState(() {
      coverURL = currentFromPoolData?["Cover"];
      yo = currentFromPoolData?["Title"];
      description = currentFromPoolData?["Description"];
      duration = currentFromPoolData?["Duration"];
      rating = currentFromPoolData?["Rating"];
      year = currentFromPoolData?["Year"];

      genres = currentFromPoolData?["Genres"];

      // isLoading = false;
    });
  }

  cycleBuffer() {
    currentImage = cachedImage;
    currentFromPoolData = fromPoolData;

    currentRandomRefFromPool = randomRefFromPool;

    if (currentCard == 1) {
      currentImage1 = currentImage;
    } else if (currentCard == 2) {
      currentImage2 = currentImage;
    } else if (currentCard == 3) {
      currentImage3 = currentImage;
    }
  }

  void like() {
    _buttonEnabled = false;
    _delayActive = true;
    _methodsRunning = true;

    Timer(Duration(milliseconds: _delay), () {
      _delayActive = false;
      if (_methodsRunning == false) {
        setState(() {
          _buttonEnabled = true;
        });
      }
    });

    final sessionDocRef = db.collection("Sessions").doc(sessionID.toString());

    if (host == true) {
      sessionDocRef.update({
        'Likes1': FieldValue.arrayUnion([currentRandomRefFromPool]),
      });
    }
    if (host == false || mobileDebug == true) {
      sessionDocRef.update({
        'Likes2': FieldValue.arrayUnion([currentRandomRefFromPool]),
      });
    }

    if (seenDocs.length + 5 >= numberOfItems) {
      AddDocToPool(context);
    }

    cycleBuffer();
    setDocState();

    GetDocFromPool();

    _methodsRunning = false;

    if (_buttonEnabled == false && _delayActive == false) {
      setState(() {
        _buttonEnabled = true;
      });
    }
  }

  void dislike() {
    _buttonEnabled = false;
    _delayActive = true;
    _methodsRunning = true;

    Timer(Duration(milliseconds: _delay), () {
      _delayActive = false;
      if (_methodsRunning == false) {
        setState(() {
          _buttonEnabled = true;
        });
      }
    });

    final sessionDocRef = db.collection("Sessions").doc(sessionID.toString());

    if (host == true) {
      sessionDocRef.update({
        'Dislikes1': FieldValue.arrayUnion([currentRandomRefFromPool]),
      });
    }
    if (host == false || mobileDebug == true) {
      sessionDocRef.update({
        'Dislikes2': FieldValue.arrayUnion([currentRandomRefFromPool]),
      });
    }

    if (seenDocs.length + 5 >= numberOfItems) {
      AddDocToPool(context);
    }

    cycleBuffer();
    setDocState();

    GetDocFromPool();
    _methodsRunning = false;

    if (_buttonEnabled == false && _delayActive == false) {
      setState(() {
        _buttonEnabled = true;
      });
    }
  }

  cycleRight() {
    print("swipe right");
    HapticFeedback.mediumImpact();

    img1Vis = true;
    img2Vis = true;
    img3Vis = true;

    dur1 = _finDur.toInt();
    dur2 = _finDur.toInt();
    dur3 = _finDur.toInt();

    if (currentCard == 1) {
      currentCard = 3;
    } else {
      currentCard -= 1;
    }

    cycleCard(false);
  }

  cycleLeft() {
    print("swipe left");
    HapticFeedback.mediumImpact();

    img1Vis = true;
    img2Vis = true;
    img3Vis = true;

    dur1 = _finDur.toInt();
    dur2 = _finDur.toInt();
    dur3 = _finDur.toInt();

    if (currentCard == 3) {
      currentCard = 1;
    } else {
      currentCard += 1;
    }

    cycleCard(true);
  }

  cycleCard(bool left) {
    setState(() {
      if (currentCard == 1) {
        if (left) {
          dur3 =
              calcDuration(_finDur, _dragVelocity, currentCard, true).toInt();
          img2Vis = false;
        } else {
          dur2 =
              calcDuration(_finDur, _dragVelocity, currentCard, false).toInt();
          img3Vis = false;
        }

        img1Pos = position2;
        img2Pos = position3;
        img3Pos = position1;
      } else if (currentCard == 2) {
        if (left) {
          dur1 =
              calcDuration(_finDur, _dragVelocity, currentCard, true).toInt();
          img3Vis = false;
        } else {
          dur3 =
              calcDuration(_finDur, _dragVelocity, currentCard, false).toInt();
          img1Vis = false;
        }

        img1Pos = position1;
        img2Pos = position2;
        img3Pos = position3;
      } else if (currentCard == 3) {
        if (left) {
          dur2 =
              calcDuration(_finDur, _dragVelocity, currentCard, true).toInt();
          img1Vis = false;
        } else {
          dur1 =
              calcDuration(_finDur, _dragVelocity, currentCard, false).toInt();
          img2Vis = false;
        }

        img1Pos = position3;
        img2Pos = position1;
        img3Pos = position2;
      }
    });
  }

  setInitPos(BuildContext context) {
    position1 = -1 * MediaQuery.of(context).size.width / 2 - _offset;
    position2 = MediaQuery.of(context).size.width / 2 - _offset;
    position3 = MediaQuery.of(context).size.width * 1.5 - _offset;

    img1Pos = position1;
    img2Pos = position2;
    img3Pos = position3;

    // currentImage1 = currentImage;
    //currentImage2 = currentImage;
  }

  initVars() {
    currentCard = 2;

    _yOffset = 0.0;
    _dragVelocity = 0.0;
    dur = 0;
    ogPos = 0;

    img1Pos = 0;
    img2Pos = 0;
    img3Pos = 0;

    img1Vis = true;
    img2Vis = true;
    img3Vis = true;

    position1 = 0;
    position2 = 0;
    position3 = 0;

    coverURL = "";
    yo = "";
    description = "";
    duration = "";
    rating = "";
    year = "";
    genres = "";
  }

  @override
  void initState() {
    super.initState();
    initVars();
    img1Vis = true;
    img2Vis = true;
    img3Vis = true;
    PopulatePool();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        ogPos = MediaQuery.of(context).size.width / 2 - 125;
        setInitPos(context);
      });
    });
  }

  Future<void> PopulatePool() async {
    for (int i = 0; i < 3; i++) {
      await AddDocToPool(context);
      print("lil teca");
    }
    print("snoop");
    await GetDocFromPool();
    await cycleBuffer();
    await setDocState();
    await GetDocFromPool();
    setState(() {
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
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ThemeColor.darkGray,
          body: Center(
            child: Stack(
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      if (_buttonEnabled == true) {
                        setState(() {
                          if (currentCard == 1) {
                            img1Pos += details.delta.dx;
                          } else if (currentCard == 2) {
                            img2Pos += details.delta.dx;
                          } else {
                            img3Pos += details.delta.dx;
                          }
                        });
                      }
                    },
                    onPanStart: (details) {
                      dur = 0;
                      dur1 = 0;
                      dur2 = 0;
                      dur3 = 0;
                    },
                    onPanEnd: (details) {
                      _dragVelocity = details.velocity.pixelsPerSecond.dx;
                      if (currentCard == 1) {
                        if (img1Pos - ogPos > swipeThreshold) {
                          setState(() {
                            cycleRight();
                            like();
                          });
                        } else if (img1Pos - ogPos < -swipeThreshold) {
                          setState(() {
                            cycleLeft();
                            dislike();
                          });
                        } else {
                          setState(() {
                            dur1 = rDur;
                            img1Pos = ogPos;
                          });
                        }
                      } else if (currentCard == 2) {
                        if (img2Pos - ogPos > 50) {
                          setState(() {
                            cycleRight();
                            like();
                          });
                        } else if (img2Pos - ogPos < -swipeThreshold) {
                          setState(() {
                            cycleLeft();
                            dislike();
                          });
                        } else {
                          setState(() {
                            dur2 = rDur;
                            img2Pos = ogPos;
                          });
                        }
                      } else if (currentCard == 3) {
                        if (img3Pos - ogPos > 50) {
                          setState(() {
                            cycleRight();
                            like();
                          });
                        } else if (img3Pos - ogPos < -swipeThreshold) {
                          setState(() {
                            cycleLeft();
                            dislike();
                          });
                        } else {
                          setState(() {
                            dur3 = rDur;
                            img3Pos = ogPos;
                          });
                        }
                      }
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Container(
                            height: 375,
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: dur1),
                                  curve: Curves.easeInOut,
                                  left: img1Pos,
                                  top: _yOffset,
                                  child: Opacity(
                                    opacity: img1Vis ? 1 : 0,
                                    child: Container(
                                      height: 375,
                                      width: 250,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image(
                                          image: currentImage1,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: dur2),
                                  curve: Curves.easeInOut,
                                  left: img2Pos,
                                  top: _yOffset,
                                  child: Opacity(
                                    opacity: img2Vis ? 1 : 0,
                                    child: Container(
                                      height: 375,
                                      width: 250,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image(
                                          image: currentImage2,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedPositioned(
                                  duration: Duration(milliseconds: dur3),
                                  curve: Curves.easeInOut,
                                  left: img3Pos,
                                  top: _yOffset,
                                  child: Opacity(
                                    opacity: img3Vis ? 1 : 0,
                                    child: Container(
                                      height: 375,
                                      width: 250,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image(
                                          image: currentImage3,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Container(
                                //   height: 375,
                                //   width: 250,
                                //   child: ClipRRect(
                                //     borderRadius: BorderRadius.circular(20),
                                //     child: Image(
                                //       image: currentImage,
                                //       fit: BoxFit.cover,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  yo,
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
                                  height: 6,
                                ),
                                Text(
                                  genres,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.textGray,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        year,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: ThemeColor.offWhite,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        rating,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: ThemeColor.offWhite,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        duration,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: ThemeColor.offWhite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'year',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: ThemeColor.textGray,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'rating',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: ThemeColor.textGray,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'duration',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: ThemeColor.textGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 120,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    child: Text(
                                      description,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        height: 1.45,
                                        fontWeight: FontWeight.w400,
                                        color: ThemeColor.textGray,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: Opacity(
                          opacity: _buttonEnabled ? 1.0 : 0.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColor.lightGray,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.rotate(
                                  angle: math.pi / 2,
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 40,
                                  ),
                                ),
                                SizedBox(width: 0),
                                Text(
                                  'Nah',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.offWhite,
                                  ),
                                ),
                                SizedBox(width: 12),
                              ],
                            ),
                            onPressed: () {
                              if (_buttonEnabled == true) {
                                cycleLeft();
                                dislike();
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: Opacity(
                          opacity: _buttonEnabled ? 1.0 : 0.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColor.lightGray,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.rotate(
                                  angle: math.pi / 2,
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    size: 40,
                                  ),
                                ),
                                SizedBox(width: 0),
                                Text(
                                  'Sure',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeColor.offWhite,
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                            onPressed: () {
                              if (_buttonEnabled == true) {
                                cycleRight();
                                like();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 26)
                ]),
                if (Platform.isAndroid)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Beta v' + version,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ThemeColor.textGray,
                        ),
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
                            MaterialPageRoute(
                                builder: (context) => RankingPage()),
                          );
                        },
                      ),
                    ),
                  ),
                LeaveSessionButton(),
                // Positioned(
                //   top: 40,
                //   right: 10,
                //   child: Align(
                //     alignment: Alignment.topRight,
                //     child: IconButton(
                //       onPressed: () {
                //         showDialog(
                //           context: context,
                //           barrierDismissible: true,
                //           builder: (BuildContext context) {
                //             return TinderDialog();
                //           },
                //         );
                //       },
                //       icon: Icon(Icons.help_outline,
                //           color: ThemeColor.handleGray),
                //     ),
                //   ),
                // ),
                if (tutCompleted == false)
                  Tutorial(
                    phase: 4,
                    bodyText: text4,
                    buttonText: buton4,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
