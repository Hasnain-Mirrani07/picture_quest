import 'package:flutter/material.dart';
import 'dart:io';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

class SettingsView extends StatefulWidget {
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool saveToDevice = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
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
              onPressed: () {
                //Sign out
              },
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
