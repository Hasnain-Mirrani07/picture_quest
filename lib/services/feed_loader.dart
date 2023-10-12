import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class FeedLoader {
  FeedLoader();
  int postLength = 0;
  int newLength = 0;
  Future<int> checkNewPostLength() async {
    //TOUTC
    var today = DateTime.now().toUtc().toString();
    var todayID = today.substring(0, 11);

    var db = await FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      QuerySnapshot qs = await db
          .collection('public_posts')
          .doc(todayID)
          .collection('posts')
          .get();
      newLength = qs.docs.length;
      print("lllllll  post legth increase ----------- $newLength");
    }
    return newLength;
  }

  Stream<List<Post>> fetchTodayPosts() async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    //TOUTC
    var today = DateTime.now().toUtc().toString();
    var todayID = today.substring(0, 11);

    var db = await FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      QuerySnapshot qs = await db
          .collection('public_posts')
          .doc(todayID)
          .collection('posts')
          .get();
      postLength = qs.docs.length;
      print("lllllll ----------- $postLength");
      await prefs.setInt("postLength", postLength);
      // var docs = qs.docs.map((doc) => doc.data()).toList();
      List<Post> postsReceived = [];
      for (var doc in qs.docs) {
        var docId = doc.id;

        var docInfo = doc.data() as Map<String, dynamic>?;
        var imageData = await getImage(docInfo?['image_id']);
        //check if the user id is in the likes array and if so set liked to true
        var liked = false;
        var likes = docInfo?['likes'];
        if (likes != null) {
          for (var like in likes) {
            if (like == user.uid) {
              liked = true;
            }
          }
        }
        //get the document name

        Post post = await Post(
          imageBytes: imageData,
          location: docInfo?['location'],
          displayName: docInfo?['display_name'],
          liked: liked,
          postId: docId,
        );
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

  void addLike(String postId, bool alreadyLiked) {
    var db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      //For now just going to directly add stars to each post

      var today = DateTime.now().toUtc().toString();
      var todayID = today.substring(0, 11);
      if (alreadyLiked) {
        db
            .collection('public_posts')
            .doc(todayID)
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayRemove([userId])
        });
        return;
      }
      db
          .collection('public_posts')
          .doc(todayID)
          .collection('posts')
          .doc(postId)
          .update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }
}

class Post {
  String? image;
  String location;
  String displayName;
  File? imageFile;
  Uint8List? imageBytes;
  bool liked = false;
  String? postId;

  Post(
      {this.image,
      required this.location,
      required this.displayName,
      this.imageFile,
      this.imageBytes,
      this.liked = false,
      this.postId});
}
