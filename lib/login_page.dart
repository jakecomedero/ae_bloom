import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Primary Theme Color matching AEBloom Brand
  final Color _pinkColor = const Color(0xFFD4778B);

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2), // Light gray background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flower Icon Logo
                Icon(
                  Icons.local_florist,
                  size: 90,
                  color: _pinkColor,
                ),
                const SizedBox(height: 20),

                // App Title: AEBLOOM
                Text(
                  'AEBLOOM',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 48,
                    letterSpacing: 3,
                    color: const Color(0xFF2E4036), // Deep forest green
                  ),
                ),

                // Tagline
                Text(
                  'Excellence in Every Bloom',
                  style: GoogleFonts.sansita(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 35),

                // Email Input Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password Input Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pinkColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member? ',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Register now',
                        style: TextStyle(
                          color: _pinkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}