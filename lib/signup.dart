import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // YEH NAYA IMPORT ADD KARO
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:task3/loingscreen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // YEH NAYA CONTROLLER ADD KARO
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // YEH NAYA LINE ADD KARO

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Firebase mein user create karo
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );

        // YEH NAYA CODE: Firestore mein user data save karo
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(), // User ka naam
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'userId': userCredential.user!.uid,
        });

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        String message = 'Signup failed';
        if (e.code == 'email-already-in-use') {
          message = 'This email is already in use';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3BE85),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.green,
                child: Image.network(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTENE15-RpIz1PL7ER6mayC-5tjtb84NCbKfg&s',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Sign up',
                  style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 15),

              // Full Name Field (YEH FIELD UPDATE KARO)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _nameController, // YEH CONTROLLER ADD KARO
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    fillColor: const Color(0xFFE3BE85),
                    filled: true,
                    prefixIcon:
                    const Icon(Icons.person, color: Colors.black, size: 28),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),

              // Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: const Color(0xFFE3BE85),
                    filled: true,
                    prefixIcon:
                    const Icon(Icons.email_outlined, color: Colors.black, size: 28),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
              ),

              // Password
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 18),
                child: TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter password',
                    fillColor: const Color(0xFFE3BE85),
                    filled: true,
                    prefixIcon: const Icon(Icons.lock, color: Colors.black, size: 28),
                    suffixIcon:
                    const Icon(Icons.remove_red_eye, color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),

              // Confirm Password
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 18),
                child: TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    fillColor: const Color(0xFFE3BE85),
                    filled: true,
                    prefixIcon: const Icon(Icons.lock, color: Colors.black, size: 28),
                    suffixIcon:
                    const Icon(Icons.remove_red_eye, color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                onTap: _handleSignup,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 58,
                  width: 180,
                  child: const Center(
                    child: Text('Submit',
                        style: TextStyle(
                            fontSize: 25, color: Colors.white)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('If you have an account? ',
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text('Sign in',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  )
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: 20,
                      endIndent: 10,
                    ),
                  ),
                  const Text("OR"),
                  Expanded(
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                      indent: 10,
                      endIndent: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.google, size: 40),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}