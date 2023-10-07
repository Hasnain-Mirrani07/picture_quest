import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:picture_quest/login_page.dart';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

class SettingsView extends StatefulWidget {
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool saveToDevice = true;

  void _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignUpScreen()),
          (Route<dynamic> route) => false);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          title: const Text(
            'Settings',
            style: TextStyle(fontSize: 32),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25),
            const Row(
              children: [
                Spacer(),
                Text(
                  'ethanalvey',
                  style: TextStyle(color: foregroundColor, fontSize: 22),
                ),
                Spacer()
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const SizedBox(width: 25),
                const Text(
                  'Save Images to Device',
                  style: TextStyle(color: foregroundColor, fontSize: 16),
                ),
                const Spacer(),
                Switch(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Color.fromARGB(255, 63, 63, 63),
                    activeColor: foregroundColor,
                    inactiveThumbColor: Colors.white,
                    value: saveToDevice,
                    onChanged: (bool value) {
                      setState(() {
                        saveToDevice = !saveToDevice;
                      });
                    }),
                const SizedBox(width: 25)
              ],
            ),
            const Spacer(),
            //Red text button that says 'Sign Out'
            TextButton(
              onPressed: _handleSignOut,
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red, fontSize: 22),
              ),
            ),
            const SizedBox(height: 50)
          ],
        ));
  }
}
