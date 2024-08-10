import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:io';
import "dart:math" as math;

import 'package:url_launcher/url_launcher.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'globals.dart';
import 'library.dart';

import 'ranking_page.dart';
import 'tinder_page.dart';
import 'podium_page.dart';

FetchLatestVersion(BuildContext context) async {
  final DocumentReference resourceDoc = FirebaseFirestore.instance
      .collection('Resources')
      .doc('Resource_Document');
  final DocumentSnapshot snapshot = await resourceDoc.get();
  final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  latestIosVersion = data?['iOS_Version'] as String;
  latestAndroidVersion = data?['Android_Version'] as String;
  devVersion = data?['Dev_Version'] as String;

  if (((Platform.isIOS && version != latestIosVersion) ||
          (Platform.isAndroid && version != latestAndroidVersion)) &&
      version != devVersion) {
    versionUpToDate = false;
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (Platform.isIOS) {
      ShowUpdateDialog(context);
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return OutdatedVersionDialog(
            message:
                'Your version is out of date. Please download the latest version.',
          );
        },
      );
    }
  } else {
    versionUpToDate = true;
    print("version up to date");
  }
}

fetchResources() async {
  final DocumentReference resourceDoc = FirebaseFirestore.instance
      .collection('Resources')
      .doc('Resource_Document');
  final DocumentSnapshot snapshot = await resourceDoc.get();
  final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  collectionName = data?['Collection_Name'] as String;
}

fetchPosters(BuildContext context) async {
  final DocumentReference homeDoc = FirebaseFirestore.instance
      .collection('Resources')
      .doc('Homepage_Posters');
  final DocumentSnapshot homeSnapshot = await homeDoc.get();
  final Map<String, dynamic>? homeData =
      homeSnapshot.data() as Map<String, dynamic>?;

  imageUrls = [
    homeData?['Poster1'] as String,
    homeData?['Poster2'] as String,
    homeData?['Poster3'] as String,
    homeData?['Poster4'] as String,
    homeData?['Poster5'] as String,
  ];

  // Precache the images
  for (var imageUrl in imageUrls) {
    await precacheImage(NetworkImage(imageUrl), context);
  }
  print("before yo 1");
}

ShowUpdateDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Download latest version'),
        content: const Text('Please download the latest version to continue.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Download'),
            onPressed: () {
              launchURL();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

launchURL() async {
  String url = 'https://flutter.io';
  if (Platform.isIOS) {
    url = iosLink;
  } else if (Platform.isAndroid) {
    url = androidLink;
  }

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

void createSession(BuildContext context) async {
  bool alreadyExists = false;
  int tries = 0;
  math.Random sessionRandom = math.Random();

  do {
    sessionID = sessionRandom.nextInt(90000) + 10000;

    var docRef = await FirebaseFirestore.instance
        .collection("Sessions")
        .doc(sessionID.toString());
    var snapshot = await docRef.get();

    if (tries > 100) {
      tries = 0;
      print("too many trires. Something went wrong");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong while creating session ID")),
      );
      Home(context);
      break;
    }

    if (snapshot.exists) {
      print("Session ID already exists");
      alreadyExists = true;
      tries++;
    } else {
      alreadyExists = false;
    }
  } while (alreadyExists == true);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference sessions = firestore.collection('Sessions');
  Map<String, dynamic> sessionData = {
    'Movies': movies,
    'Shows': shows,
    'SessionID': sessionID,
    'Joined': false,
    'Creation_Date': FieldValue.serverTimestamp(),
  };
  sessions
      .doc(sessionID.toString())
      .set(sessionData)
      .then((value) => print('Session created'))
      .catchError((error) => print('Error creating session: $error'));

  createListener(context);
}

void createListener(BuildContext context) {
  print("Listener Created for document: " + sessionID.toString());
  sessionDocRef = db.collection("Sessions").doc(sessionID.toString());
  sessionDocRef.snapshots().listen(
    (event) async {
      //print("Detected change");
      if (joined == false && host == true) {
        await CheckIfJoined(context);
      }
      checkCommonElements(context);

      if (onRankingPage == true) {
        final sessionDocRef =
            db.collection("Sessions").doc(sessionID.toString());
        final doc = await sessionDocRef.get();
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('Ranking1') && data.containsKey('Ranking2')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PodiumPage()),
          );
        }
      }
    },
    onError: (error) => print("Listen failed: $error"),
  );
}

CheckIfJoined(BuildContext context) async {
  final doc = await sessionDocRef.get();
  final data = doc.data() as Map<String, dynamic>;
  joined = data["Joined"];

  if (startedSession == false && joined == true) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TinderPage()),
    );
    startedSession = true;
  }
}

int numberOfItems = 0;

DocumentReference randomDocRef =
    db.collection("Sessions").doc(sessionID.toString());

AddDocToPool(BuildContext context) async {
  final CollectionReference collection = db.collection(collectionName);
  QuerySnapshot snapshot;
  if (movies == true && shows == true) {
    snapshot = await collection.get();
  } else if (movies == true) {
    snapshot = await collection.where('Is_Show', isEqualTo: false).get();
  } else if (shows == true) {
    snapshot = await collection.where('Is_Show', isEqualTo: true).get();
  } else {
    snapshot = await collection.get();
  }

  if (snapshot.size > numberOfItems + 1) {
    int randomIndex =
        snapshot.size > 0 ? math.Random().nextInt(snapshot.size) : 0;
    DocumentSnapshot randomDocument = snapshot.docs[randomIndex];

    randomDocRef = randomDocument.reference;

    final DocumentReference sessionDocRef =
        db.collection('Sessions').doc(sessionID.toString());
    DocumentSnapshot sessionSnapshot = await sessionDocRef.get();
    List<dynamic>? pool =
        (sessionSnapshot.data() as Map<String, dynamic>?)?['Pool']
            ?.cast<dynamic>();

    int loopCounter = 0;

    while (pool != null && pool.contains(randomDocRef)) {
      randomIndex = math.Random().nextInt(snapshot.size);
      randomDocument = snapshot.docs[randomIndex];
      randomDocRef = randomDocument.reference;
      print("duplicate");

      loopCounter++;
      if (loopCounter > 1000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Something went wrong :( please restart the app")),
        );
        print("Looped 1000 times and couldnt find document");
        break;
      }
    }

    sessionDocRef.update({
      'Pool': FieldValue.arrayUnion([randomDocRef])
    });
  } else {
    print("All elligible items have been added to Pool");
  }
}

Future<void> checkCommonElements(BuildContext context) async {
  final DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('Sessions')
      .doc(sessionID.toString())
      .get();
  final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

  final List<dynamic>? likes1 = data['Likes1'];
  final List<dynamic>? likes2 = data['Likes2'];
  final Set<dynamic> likes1Set = Set.from(likes1 ?? []);
  final Set<dynamic> likes2Set = Set.from(likes2 ?? []);

  commonElements = likes1Set.intersection(likes2Set);
  if (commonElements.length >= 5 && onRankingPage == false) {
    //print('>= 5 mutual likes');
    onRankingPage = true;
    setMutualLikes();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RankingPage()),
    );
  } else {
    //print('< 5 mutual likes');
  }
}

void setMutualLikes() async {
  final List<dynamic> commonElementsList = List.from(commonElements);
  await FirebaseFirestore.instance
      .collection('Sessions')
      .doc(sessionID.toString())
      .update({'MutualLikes': commonElementsList});
}

void Home(BuildContext context) {
  host = false;
  sessionID = 00000;
  startedSession = false;
  seenDocs = [];
  movies = false;
  shows = false;
  onRankingPage = false;
  joined = false;

  Navigator.of(context).popUntil((route) => route.isFirst);
}

double calcDuration(_finDur, _dragVelocity, currentCard, left) {
  double dRemaining;
  double dScale;

  if (currentCard == 1) {
    if (left) {
      dRemaining = (position1 - position2) - (img3Pos - position2);
      dScale = (dRemaining / (position1 - position2));
    } else {
      dRemaining = (position3 - position2) - (img2Pos - position2);
      dScale = (dRemaining / (position3 - position2));
    }
  } else if (currentCard == 2) {
    if (left) {
      dRemaining = (position1 - position2) - (img1Pos - position2);
      dScale = (dRemaining / (position1 - position2));
    } else {
      dRemaining = (position3 - position2) - (img3Pos - position2);
      dScale = (dRemaining / (position3 - position2));
    }
  } else {
    if (left) {
      dRemaining = (position1 - position2) - (img2Pos - position2);
      dScale = (dRemaining / (position1 - position2));
    } else {
      dRemaining = (position3 - position2) - (img1Pos - position2);
      dScale = (dRemaining / (position3 - position2));
    }
  }

  double pxSec = dRemaining / ((_finDur * dScale) / 1000);
  double velScale;
  double adjustedDuration;

  if (_dragVelocity < -50 || _dragVelocity > 50) {
    velScale = _dragVelocity / pxSec;
  } else {
    velScale = 0;
  }

  if (velScale > 1) {
    adjustedDuration = (_finDur * dScale) / (velScale);
  } else {
    adjustedDuration = (_finDur * dScale);
  }

  return adjustedDuration;
}
