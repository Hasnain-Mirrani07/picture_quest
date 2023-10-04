import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

class FeedLoader {
  FeedLoader();

  Stream<List<Post>> fetchTodayPosts() async* {
    //TOUTC
    var today = DateTime.now().toUtc().toString();
    var todayID = today.substring(0, 11);

    var db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      QuerySnapshot qs = await db
          .collection('public_posts')
          .doc(todayID)
          .collection('posts')
          .get();

      var docs = qs.docs.map((doc) => doc.data()).toList();
      List<Post> postsReceived = [];
      for (var doc in docs) {
        var docInfo = doc as Map<String, dynamic>?;
        var imageData = await getImage(docInfo?['image_id']);
        Post post = Post(
            imageBytes: imageData,
            location: docInfo?['location'],
            displayName: docInfo?['display_name']);
        postsReceived.add(post);
        yield List.of(postsReceived);
      }
      // return postsReceived;
    }

    // return [];
  }

//Function gets image from Firebase Storage
  Future<Uint8List?> getImage(String imageId) async {
    final ref = FirebaseStorage.instance.ref().child(imageId);
    try {
      const maxSize = 7024 * 1024;
      final Uint8List? data = await ref.getData(maxSize);
      return data;
    } on FirebaseException catch (e) {
      return null;
    }
  }

  Future<String?> getLocation() async {
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
  Future<String> getDisplayName() async {
    var db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      return db
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
}

class Post {
  String? image;
  String location;
  String displayName;
  File? imageFile;
  Uint8List? imageBytes;

  Post(
      {this.image,
      required this.location,
      required this.displayName,
      this.imageFile,
      this.imageBytes});
}
