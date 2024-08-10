import 'package:cloud_firestore/cloud_firestore.dart';

// Manually defined
String version = "0.7.2";
bool debug = false;

bool versionCheckEnabled = false;

const String iosLink =
    "https://install.appcenter.ms/users/Buhlahkay/apps/Netflix-Tinder-iOS";
const String androidLink =
    "https://install.appcenter.ms/users/buhlahkay/apps/netflix-tinder-android/distribution_groups/beta%20testers";

String shareMessage =
    "Join me on MixFlix\n\nDownload for iOS:\n" + testflightLink + "\n\nDownload for Android:\nhttps://install.appcenter.ms/users/buhlahkay/apps/netflix-tinder-android/distribution_groups/beta%20testers";


String testflightLink = "https://testflight.apple.com/join/zonhEhVX";

String latestIosVersion = "";
String latestAndroidVersion = "";
String devVersion = "";
String collectionName = "";

bool versionUpToDate = false;
bool host = false;


bool movies = false;
bool shows = false;

int sessionID = 00000;

bool mobileDebug = false;

bool startedSession = false;
bool joined = false;

bool debugButtonVis = false;


final db = FirebaseFirestore.instance;

DocumentReference sessionDocRef = db.collection("Sessions").doc(sessionID.toString());

bool onRankingPage = false;

Set<dynamic> commonElements = 0 as Set;

Set<dynamic> averageElements = 0 as Set;

List<String> imageUrls = [];
