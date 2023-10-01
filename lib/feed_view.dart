import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:picture_quest/image_review.dart';
import 'package:picture_quest/services/feed_loader.dart';
import 'camera_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/feed_loader.dart';
import 'dart:io';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

class FeedView extends StatefulWidget {
  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  FeedLoader fl = FeedLoader();

  void _activateCamera() async {
    File? imagePicked;
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => imagePicked = imageTemp);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ImageReviewer(image: imagePicked)),
      );
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            ListView(
              children: <Widget>[
                const SizedBox(height: 60),
                FutureBuilder(
                    future: fl.fetchTodayPosts(),
                    builder: (context, snapshot) {
                      return Column(children: [
                        for (var post in snapshot.data ?? [])
                          PicturePost(
                            locationText: post.location,
                            displayName: post.displayName,
                            imageURL: post.image,
                          ),
                        const SizedBox(height: 15)
                      ]);
                    }),
                // PicturePost(),
                // const SizedBox(
                //   height: 15,
                // ),
                // PicturePost(),
                // const SizedBox(
                //   height: 15,
                // ),
                // PicturePost(),
                const SizedBox(height: 100)
              ],
            ),
            Column(children: [
              const SizedBox(height: 40),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: foregroundColor,
                      backgroundColor: buttonColor),
                  onPressed: () => {},
                  child: const Row(children: [
                    Spacer(),
                    Text(
                      'Water',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                    Icon(Icons.expand_more)
                  ])),
            ])
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _activateCamera,
        backgroundColor: buttonColor,
        child: const Icon(
          Icons.photo_camera,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PicturePost extends StatefulWidget {
  final String? locationText;
  final String? displayName;
  final String? imageURL;
  PicturePost({this.locationText, this.displayName, this.imageURL});

  @override
  _PicturePostState createState() => _PicturePostState();
}

class _PicturePostState extends State<PicturePost> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            decoration:
                BoxDecoration(border: Border.all(color: foregroundColor)),
            child: Image.network(widget.imageURL ?? '')),
        Container(
            height: 25,
            decoration:
                BoxDecoration(border: Border.all(color: foregroundColor)),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 16),
                const Icon(Icons.place, color: foregroundColor),
                Text(widget.locationText ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: foregroundColor)),
                const Spacer(),
                const Spacer(),
                Text(widget.displayName ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: foregroundColor)),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        pressed = !pressed;
                      });
                    },
                    child: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: pressed == true
                            ? const Icon(
                                Icons.star,
                                color: foregroundColor,
                              )
                            : const Icon(
                                Icons.star_border,
                                color: foregroundColor,
                              ))),
                // IconButton(
                //     color: foregroundColor,
                //     icon: Padding(
                //         padding: EdgeInsets.zero,
                //         child: pressed == true
                //             ? const Icon(Icons.star)
                //             : const Icon(Icons.star_border)),
                //     onPressed: () {
                //       setState(() {
                //         pressed = !pressed;
                //       });
                //     })
              ],
            ))
      ],
    );
  }
}
