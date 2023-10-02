import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class FeedLoader {
  FeedLoader();

  Future<List<Post>> fetchTodayPosts() async {
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
        var loadedImage = await alternateLoad(docInfo?['image_id']);
        Post post = Post(
            image: loadedImage,
            location: docInfo?['location'],
            displayName: docInfo?['display_name']);
        postsReceived.add(post);
      }
      return postsReceived;
    }

    return [];
  }

  Future<String> alternateLoad(String id) async {
    final ref = FirebaseStorage.instance.ref().child(id);
    var url = ref.getDownloadURL();
    return url;
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
}

class Post {
  String? image;
  String location;
  String displayName;
  File? imageFile;

  Post(
      {this.image,
      required this.location,
      required this.displayName,
      this.imageFile});
}
