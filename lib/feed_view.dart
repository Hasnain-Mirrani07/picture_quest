import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:picture_quest/image_review.dart';
import 'package:picture_quest/services/feed_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:picture_quest/settings_view.dart';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

class FeedView extends StatefulWidget {
  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  FeedLoader fl = FeedLoader();
  Post? preLoadedPost;

  void _activateCamera() async {
    File? imagePicked;
    try {
      final location = await fl.getLocation();
      final displayName = await fl.getDisplayName();
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      preLoadedPost = Post(
          imageFile: imageTemp,
          location: location ?? '',
          displayName: displayName);
      setState(() => imagePicked = imageTemp);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ImageReviewer(image: imagePicked)),
      );
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _settingsNavigate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SettingsView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40,
          title: Row(
            children: [
              const Spacer(),
              const Spacer(),
              const Text(
                'FOCUS',
                style: TextStyle(fontSize: 32),
              ),
              const Spacer(),
              IconButton(
                  onPressed: _settingsNavigate,
                  icon: const Icon(
                    Icons.person,
                    color: buttonColor,
                  ))
            ],
          )),
      body: Center(
        child: Stack(
          children: [
            RefreshIndicator(
                color: buttonColor,
                displacement: 100,
                onRefresh: _refresh,
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 60),
                    //If preLoadedPost is not null, display it as a PicturePost
                    preLoadedPost != null
                        ? PicturePost(
                            locationText: preLoadedPost?.location,
                            displayName: preLoadedPost?.displayName,
                            image: preLoadedPost?.imageFile,
                          )
                        : Container(),

                    StreamBuilder<List<Post>>(
                        stream: fl.fetchTodayPosts(),
                        builder: (context, snapshot) {
                          return Column(children: [
                            for (var post in snapshot.data ?? [])
                              post.imageBytes != null
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullscreenImage(
                                              imageBytes: post.imageBytes!,
                                            ),
                                          ),
                                        );
                                      },
                                      child: PicturePost(
                                        locationText: post.location,
                                        displayName: post.displayName,
                                        imageBytes: post.imageBytes,
                                      ),
                                    )
                                  : Container(),
                          ]);
                        }),
                    const SizedBox(height: 100)
                  ],
                )),
            // Column(children: [
            //   const SizedBox(height: 40),
            //   ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //           foregroundColor: foregroundColor,
            //           backgroundColor: buttonColor),
            //       onPressed: () => {},
            //       child: const Row(children: [
            //         Spacer(),
            //         Text(
            //           'Water',
            //           style: TextStyle(
            //             fontSize: 40,
            //           ),
            //           textAlign: TextAlign.center,
            //         ),
            //         Spacer(),
            //         Icon(Icons.expand_more)
            //       ])),
            // ])
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

  Future<void> _refresh() async {
    fl.fetchTodayPosts();
    preLoadedPost = null;
    setState(() {});
  }
}

class PicturePost extends StatefulWidget {
  final String? locationText;
  final String? displayName;
  final File? image;
  final Uint8List? imageBytes;
  const PicturePost(
      {this.locationText, this.displayName, this.image, this.imageBytes});

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
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: foregroundColor, width: 10),
                left: BorderSide(color: foregroundColor, width: 10),
                right: BorderSide(color: foregroundColor, width: 10),
              ),
            ),
            child: widget.image == null && widget.imageBytes != null
                ? Image.memory(widget.imageBytes!)
                : Image.file(
                    widget.image ?? File('picture_quest/images/black.jpg'))),
        Container(
            color: foregroundColor,
            height: 40,
            //decoration:
            //    BoxDecoration(border: Border.all(color: foregroundColor)),
            child: Row(
              children: <Widget>[
                const Spacer(),
                if (widget.locationText?.isNotEmpty ?? false)
                  const Icon(Icons.place, color: buttonColor),
                Text(widget.locationText ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: buttonColor)),
                const Spacer(),
                const Spacer(),
                Text('@${widget.displayName ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: buttonColor)),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        pressed = !pressed;
                      });
                    },
                    child: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: pressed == true
                            ? const Icon(
                                Icons.star,
                                color: buttonColor,
                              )
                            : const Icon(
                                Icons.star_border,
                                color: buttonColor,
                              ))),
              ],
            )),
        const SizedBox(height: 15)
      ],
    );
  }
}

class FullscreenImage extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;

  const FullscreenImage({Key? key, this.imageFile, this.imageBytes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: imageFile != null
              ? Image.file(imageFile!)
              : Image.memory(imageBytes!),
        ),
      ),
    );
  }
}
