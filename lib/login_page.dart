import 'package:flutter/material.dart';
import 'package:picture_quest/feed_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

const buttonColor = Colors.black;
const foregroundColor = Colors.white;

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Use Firebase Authentication to create a new user account
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // If sign-up is successful, navigate to the home screen or another screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FeedView()),
        );
      } catch (e) {
        // Handle any sign-up errors here, e.g., email already in use, weak password, etc.
        String errorMessage = "An error occurred during sign-up.";

        if (e is FirebaseAuthException) {
          errorMessage = e.message ?? "An error occurred.";
        }

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
                // You can add more validation here if needed
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FeedView()), // Replace HomeScreen with your desired screen
        );
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
