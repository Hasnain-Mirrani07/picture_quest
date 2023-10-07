import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

class ImageReviewer extends StatefulWidget {
  final File? image;

  const ImageReviewer({Key? key, this.image}) : super(key: key);

  @override
  State<ImageReviewer> createState() => _ImageReviewerState();
}

class _ImageReviewerState extends State<ImageReviewer> {
  bool showLocation = true;
  bool isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Water'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 35),
            Image.file(widget.image!),
            Column(children: [
              Row(
                children: [
                  const SizedBox(width: 25),
                  const Icon(
                    Icons.place,
                    color: Colors.white,
                  ),
                  const Text(' Show Location',
                      style: TextStyle(color: foregroundColor, fontSize: 22)),
                  const Spacer(),
                  Switch(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: const Color.fromARGB(255, 63, 63, 63),
                      activeColor: foregroundColor,
                      inactiveThumbColor: Colors.white,
                      value: showLocation,
                      onChanged: (bool value) {
                        setState(() {
                          showLocation = !showLocation;
                        });
                      }),
                  const SizedBox(width: 25)
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 25),
                  const Icon(
                    Icons.public,
                    color: Colors.white,
                  ),
                  const Text(' Public',
                      style: TextStyle(color: foregroundColor, fontSize: 22)),
                  const Spacer(),
                  Switch(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: const Color.fromARGB(255, 63, 63, 63),
                      activeColor: foregroundColor,
                      inactiveThumbColor: Colors.white,
                      value: isPublic,
                      onChanged: (bool value) {
                        setState(() {
                          isPublic = !isPublic;
                        });
                      }),
                  const SizedBox(width: 25)
                ],
              ),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                if (widget.image != null)
                  {
                    if (isPublic)
                      {_uploadPost(widget.image!, showLocation)}
                    else
                      {_uploadPrivatePost(widget.image!, showLocation)}
                  },
                Navigator.pop(context, widget.image)
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: buttonColor,
                  backgroundColor: foregroundColor),
              child: const Text(
                'Publish',
                style: TextStyle(fontSize: 24),
              ),
            )
          ],
        ));
  }

  Future<String?> _getLocation() async {
    try {
      await Geolocator.requestPermission();
      var hasPermission = await Geolocator.isLocationServiceEnabled();
      if (!hasPermission) {
        return null;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      var placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      var cityState =
          '${placemark[0].locality}, ${placemark[0].administrativeArea}';

      return cityState;
    } catch (e) {
      return null;
    }
  }

  //function that returns user display name
  Future<String> _getDisplayName() async {
    var db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      db
          .collection('users')
          .doc(userId)
          .get()
          .then((DocumentSnapshot userDoc) async {
        final data = userDoc.data() as Map<String, dynamic>?;
        var displayName = data?['display_name'];
        return displayName;
      });
    }
    return '';
  }

  void _uploadPost(File postImage, bool location) async {
    var locationString = '';
    if (location) {
      var locationRequest = await _getLocation();
      if (locationRequest != null) {
        locationString = locationRequest;
      }
    }

    var db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      db
          .collection('users')
          .doc(userId)
          .get()
          .then((DocumentSnapshot userDoc) async {
        final data = userDoc.data() as Map<String, dynamic>?;
        var displayName = data?['display_name'];
        var today = DateTime.now().toUtc().toString();
        var todayID = today.substring(0, 11);
        var imageID = await _uploadImage(postImage);
        final post = {
          "image_id": imageID,
          "location": locationString,
          "user_id": userId,
          "display_name": displayName
        };

        var postID = await db
            .collection('public_posts')
            .doc(todayID)
            .collection('posts')
            .add(post);

        db.collection('users').doc(userId).update({
          'posts': FieldValue.arrayUnion([postID.id])
        });
      });
    }
  }

  void _uploadPrivatePost(File postImage, bool location) async {
    var locationString = '';
    if (location) {
      var locationRequest = await _getLocation();
      if (locationRequest != null) {
        locationString = locationRequest;
      }
    }

    var db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      db
          .collection('users')
          .doc(userId)
          .get()
          .then((DocumentSnapshot userDoc) async {
        final data = userDoc.data() as Map<String, dynamic>?;
        var displayName = data?['display_name'];
        var today = DateTime.now().toUtc().toString();
        var todayID = today.substring(0, 11);
        var imageID = await _uploadImage(postImage);
        final post = {
          "image_id": imageID,
          "location": locationString,
          "user_id": userId,
          "display_name": displayName
        };

        var postID = await db
            .collection('private_posts')
            .doc(userId)
            .collection(todayID)
            .add(post);

        db.collection('users').doc(userId).update({
          'posts': FieldValue.arrayUnion([postID.id])
        });
      });
    }
  }

  Future<String> _uploadImage(File imageToUpload) async {
    final storageRef = FirebaseStorage.instance.ref();
    var imageKey = DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
    final imageRef = storageRef.child(imageKey);
    try {
      await imageRef.putFile(imageToUpload);
      return imageKey;
    } catch (e) {
      debugPrint(e.toString());
      return 'ERROR';
    }
  }
}
