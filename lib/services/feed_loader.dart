import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class FeedLoader {
  FeedLoader();

  Future<List<Post>> fetchTodayPosts() async {
    //TOUTC
    var today = DateTime.now().toString();
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
    var url = await ref.getDownloadURL();
    return url;
  }
}

class Post {
  String image;
  String location;
  String displayName;

  Post(
      {required this.image, required this.location, required this.displayName});
}
