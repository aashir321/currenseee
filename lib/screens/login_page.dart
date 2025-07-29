import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:currensee/services/authentication.dart';
import 'package:currensee/screens/home_page.dart';
import 'package:currensee/services/validate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isProcessing = false;
  String? email;
  String? password;
  bool _obscureText = true; // To toggle password visibility
  String? displayName;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If the user is already logged in, no need to show the login screen.
      Future.delayed(Duration.zero, () {
        // We could navigate to home page here, but this logic will be handled later.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CurrenSee',
          style: TextStyle(
              fontSize: 22,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),
                const Text(
                  'Welcome ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please sign in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Color(0xFF1A1A2E)),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFF1A1A2E)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color(0xFF1A1A2E), width: 2),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF1A1A2E)),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Color(0xFF1A1A2E)),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF1A1A2E)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF1A1A2E),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color(0xFF1A1A2E), width: 2),
                    ),
                  ),
                  style: TextStyle(color: Color(0xFF1A1A2E)),
                  validator: validatePass,
                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: onLoginSubmit,
                    child: !isProcessing
                        ? const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )
                        : const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/register');
                    },
                    child: const Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onLoginSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isProcessing = true;
      });
      await signInUser();
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> signInUser() async {
    try {
      String? errorMessage = await AuthenticationHelpler()
          .signIn(email: email.toString(), password: password.toString());

      if (errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
        return;
      }

      // After the user is signed in, check if they have a displayName in Firestore
      await _checkUsernameInFirestore();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> _checkUsernameInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Check if the displayName field exists and is not empty
        String? storedDisplayName = userDoc['displayName'];

        if (storedDisplayName != null && storedDisplayName.isNotEmpty) {
          // If username exists, navigate to home page directly
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: storedDisplayName, // Pass the username to the HomePage
          );
        } else {
          // If no username, show the username dialog
          await _showUsernameDialog();
        }
      } else {
        // Document doesn't exist, show the username dialog
        await _showUsernameDialog();
      }
    }
  }

  Future<void> _showUsernameDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Username',
            style:
                TextStyle(color: Colors.black), // Set title text color to black
          ),
          content: TextField(
            style: const TextStyle(
                color: Colors.black), // Set input text color to black
            onChanged: (value) {
              displayName = value; // Store the username in displayName
            },
            decoration: const InputDecoration(
              hintText: 'Enter your username',
              hintStyle:
                  TextStyle(color: Colors.grey), // Placeholder text color
              border:
                  OutlineInputBorder(), // Optional: Add a border for clarity
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Submit',
                style: TextStyle(
                    color: Colors.black), // Submit button text in black
              ),
              onPressed: () async {
                if (displayName != null && displayName!.isNotEmpty) {
                  await _storeUsernameInFirestore();
                  Navigator.of(context).pop();

                  // Navigate to HomePage and pass the displayName
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: displayName, // Pass the required parameter
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a username')));
                }
              },
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.black), // Cancel button text in black
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _storeUsernameInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'email': user.email,
      });
    }
  }
}
