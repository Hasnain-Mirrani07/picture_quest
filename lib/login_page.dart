import 'package:flutter/material.dart';
import 'package:picture_quest/feed_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profanity_filter/profanity_filter.dart';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;
final specialCharacters = [
  '!',
  '"',
  '#',
  '\$',
  '%',
  '&',
  '\'',
  '(',
  ')',
  '*',
  '+',
  ',',
  '-',
  '.',
  '/',
  ':',
  ';',
  '<',
  '=',
  '>',
  '?',
  '@',
  '[',
  '\\',
  ']',
  '^',
  ' ',
  '`',
  '{',
  '|',
  '}',
  '~'
];
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

void main() {
  runApp(MaterialApp(home: SignUpScreen()));
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SignUpForm(),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  bool _displayNameExists = false;

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (_displayNameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name already in use.')),
        );
        return;
      }
      try {
        // Use Firebase Authentication to create a new user account
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        //make user doc in path users and upload to firestroe
        //get the user id
        FirebaseAuth auth = FirebaseAuth.instance;
        User? user = auth.currentUser;
        if (user != null) {
          var db = FirebaseFirestore.instance;
          var displayName = _displayNameController.text;
          var userDoc = db.collection('users').doc(user.uid);
          userDoc.set({
            'display_name': displayName,
            'user_id': user.uid,
          });
          //add display name to a collection display_name
          var displayDoc = db.collection('display_names').doc(displayName);
          displayDoc.set({
            'display_name': displayName,
            'user_id': user.uid,
          });
        }

        // If sign-up is successful, navigate to the home screen or another screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FeedView()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The password provided is too weak.')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('The account already exists for that email.')),
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _displayNameController.addListener(_checkDisplayName);
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_checkDisplayName);
    super.dispose();
  }

  void _checkDisplayName() async {
    final displayName = _displayNameController.text.trim();
    final snapshot = await _firestore
        .collection('display_names')
        .where('display_name', isEqualTo: displayName)
        .limit(1)
        .get();
    setState(() {
      _displayNameExists = snapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              cursorColor: foregroundColor,
              style: const TextStyle(color: foregroundColor),
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email', // Change the label text here
                labelStyle: TextStyle(
                    color: foregroundColor), // Change the label text color here
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey), // Chge the underline color here
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          foregroundColor), // Change the focused underline color here
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              style: const TextStyle(color: foregroundColor),
              cursorColor: foregroundColor,
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password', // Change the label text here
                labelStyle: TextStyle(
                    color: foregroundColor), // Change the label text color here
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey), // Change the underline color here
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          foregroundColor), // Change the focused underline color here
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                // You can add more validation here if needed
                return null;
              },
            ),
            TextFormField(
              cursorColor: foregroundColor,
              style: const TextStyle(color: foregroundColor),
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name', // Change the label text here
                labelStyle: TextStyle(
                    color: foregroundColor), // Change the label text color here
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey), // Chge the underline color here
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          foregroundColor), // Change the focused underline color here
                ),
              ),
              validator: (value) {
                final filter = ProfanityFilter();

                if (value == null) {
                  return 'Enter a display name';
                }
                if (value.isEmpty) {
                  return 'Enter a display name';
                }
                if (filter.hasProfanity(value)) {
                  return 'Enter a valid display name';
                }
                for (var character in specialCharacters) {
                  if (value.contains(character)) {
                    return 'Enter a valid display name';
                  }
                }
                if (_displayNameExists) {
                  return 'Display name already in use';
                }
                return null;
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: buttonColor,
                  backgroundColor: foregroundColor),
              onPressed: _handleSignUp,
              child: Text('Sign Up'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: foregroundColor,
                  backgroundColor: buttonColor),
              onPressed: _navigateToSignIn,
              child: Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String email = _emailController.text.trim();
        final String password = _passwordController.text;

        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // If login is successful, navigate to the home screen or another screen
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FeedView()),
            (Route<dynamic> route) => false);
      } catch (e) {
        // Handle any sign-up errors here, e.g., email already in use, weak password, etc.
        String errorMessage = "Invalid email or password";

        // Show the error message using a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  style: const TextStyle(color: foregroundColor),
                  controller: _emailController,
                  cursorColor: foregroundColor,
                  decoration: const InputDecoration(
                    labelText: 'Email', // Change the label text hegcre
                    labelStyle: TextStyle(
                        color:
                            foregroundColor), // Change the label text color here
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey), // Chge the underline color here
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              foregroundColor), // Change the focused underline color here
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  style: const TextStyle(color: foregroundColor),
                  controller: _passwordController,
                  cursorColor: foregroundColor,
                  decoration: const InputDecoration(
                    labelText: 'Password', // Change the label text here
                    labelStyle: TextStyle(
                        color:
                            foregroundColor), // Change the label text color here
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.grey), // Change the underline color here
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              foregroundColor), // Change the focused underline color here
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: buttonColor,
                      backgroundColor: foregroundColor),
                  onPressed: _handleSignIn,
                  child: Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
