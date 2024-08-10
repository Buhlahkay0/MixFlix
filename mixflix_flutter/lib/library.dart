import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart';

import 'methods.dart';
import 'theme.dart';

class YourTile extends StatelessWidget {
  final String cover;
  final String title;
  final String genre;
  final String duration;

  final String genres;

  final cornerRounding = 10.0;

  const YourTile(
      {Key? key,
      required this.cover,
      required this.title,
      required this.genre,
      required this.duration,
      required this.genres})
      : super(key: key);

  @override
  Widget build(BuildContext context, {Key? key}) {
    return Container(
      height: 114,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColor.lightGray,
        borderRadius: BorderRadius.circular(cornerRounding),
      ),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cornerRounding),
                bottomLeft: Radius.circular(cornerRounding),
              ),
              child: Image.network(cover),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 18, bottom: 18, left: 20, right: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ThemeColor.offWhite,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    genres,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ThemeColor.textGray,
                    ),
                  ),
                  Expanded(child: Container()),
                  Text(
                    duration,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: ThemeColor.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(color: Colors.yellow, width: 2.0),
            // ),
            child: ReorderableDragStartListener(
              index: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6, left: 0),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      size: 35,
                      color: ThemeColor.handleGray,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PodiumTile extends StatelessWidget {
  final String cover;
  final String title;
  final int number;

  final cornerRounding = 10.0;

  const PodiumTile(
      {Key? key,
      required this.title,
      required this.number,
      required this.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Container(
        height: 210,
        width: 140,
        // decoration: BoxDecoration(
        //   border: Border.all(color: Colors.yellow, width: 2.0),
        // ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 135,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(cornerRounding),
                  ),
                  child: Image.network(cover),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ThemeColor.offWhite,
                  ),
                ),
              ),
            ),
            Text(
              number.toString(),
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: ThemeColor.offWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutdatedVersionDialog extends StatelessWidget {
  final String message;

  OutdatedVersionDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Required'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('Download'),
          onPressed: () async {
            String url = androidLink;

            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
      ],
    );
  }
}

class RankingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: ThemeColor.lightGray,
      titlePadding: EdgeInsets.all(0),
      title: Stack(children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close, color: ThemeColor.offWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                'Help',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: ThemeColor.offWhite,
                ),
              ),
            ),
          ],
        ),
      ]),
      content: Text(
        'Drag the tiles using the handle on the right in the order you\'d most like to watch',
        style: TextStyle(
          color: ThemeColor.offWhite,
        ),
      ),
    );
  }
}

class BetaVersionText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Positioned(
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
      );
    } else {
      return Positioned(
        bottom: 20,
        right: 20,
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
      );
    }
  }
}

class LeaveSessionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 4,
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          iconSize: 40,
          icon: Icon(Icons.chevron_left_rounded, color: ThemeColor.handleGray),
          onPressed: () {
            Home(context);
          },
        ),
      ),
    );
  }
}

class TinderDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: ThemeColor.lightGray,
      titlePadding: EdgeInsets.all(0),
      title: Stack(children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close, color: ThemeColor.offWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                'Help',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: ThemeColor.offWhite,
                ),
              ),
            ),
          ],
        ),
      ]),
      content: Text(
        "Press \"Sure\" if you're in the mood to watch the show or movie being shown or \"Nah\" if you aren't feeling it. Swipe right for \"Sure\"; swipe left for \"Nah\"",
        style: TextStyle(
          color: ThemeColor.offWhite,
        ),
      ),
    );
  }
}

class HelpText extends StatelessWidget {
  final String number;
  final String text;

  const HelpText({Key? key, required this.number, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              number,
              textAlign: TextAlign.left,
              style: GoogleFonts.montserrat(
                  height: 1.45,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ThemeColor.textGray),
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: GoogleFonts.montserrat(
                height: 1.45,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ThemeColor.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentPage = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    awaitCheat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void awaitCheat() async {
    //await fetchPosters(context);
    print("yo2");
    setState(() {});
    startImageCarousel();
  }

  void startImageCarousel() {
    // Start the timer to switch to the next image every 5 seconds
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (currentPage < imageUrls.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360, // Set the desired height for the SizedBox
      child: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        itemCount: imageUrls.length,
        onPageChanged: (int page) {
          setState(() {
            currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).primaryColor.withOpacity(1),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
