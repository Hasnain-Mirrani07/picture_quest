import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:picture_quest/settings_view.dart';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

class AccountView extends StatefulWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
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
              const Spacer(),
              const Text(
                'Account',
                style: TextStyle(fontSize: 32),
              ),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              IconButton(
                  onPressed: _settingsNavigate,
                  icon: const Icon(
                    Icons.settings,
                    color: buttonColor,
                  ))
            ],
          )),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data!.exists) {
            final documentData = snapshot.data!.data() as Map<String, dynamic>?;

            if (documentData != null && documentData.containsKey('posts')) {
              final Map<String, dynamic> posts =
                  documentData['posts'] as Map<String, dynamic>;
              return SingleChildScrollView(
                  child: Column(children: [
                const SizedBox(height: 25),
                const Row(
                  children: [
                    Spacer(),
                    Text(
                      'ethanalvey',
                      style: TextStyle(color: foregroundColor, fontSize: 22),
                    ),
                    Spacer(),
                  ],
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0),
                  shrinkWrap: true, // Important to add this
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts;
                    //get the value of the current post
                    var imageId = post.values.elementAt(index);

                    //get imageURL from the imageID
                    Reference ref = FirebaseStorage.instance.ref(imageId);

                    return FutureBuilder<String>(
                      future: ref.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        }
                        final imageUrl = snapshot.data!;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                )
              ]));
            }
          }
          return const Center(
            child: Text('No posts'),
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
