import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Successful!"), backgroundColor: Colors.green),
        );

        Navigator.pushReplacementNamed(context, "/login");
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Signup failed"), backgroundColor: Colors.redAccent),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Decorative bottom green arc
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              child: Container(
                height: height * 0.25,
                
              ),
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25).copyWith(bottom: keyboardHeight),
            child: Column(
              children: [
                SizedBox(height: height * 0.1),
                Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: keyboardHeight > 0 ? 90 : 140,
                    width: keyboardHeight > 0 ? 90 : 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("lib/assets/icon.jpg"), // can be a different image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Join Us Today!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email, color: Colors.green),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Please enter an email";
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Enter a valid email";
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock, color: Colors.green),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Please enter a password";
                              if (value.length < 6) return "Password must be at least 6 characters";
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    onPressed: _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                                      elevation: 4,
                                    ),
                                    child: Text("Sign Up", style: TextStyle(fontSize: 18)),
                                  ),
                          ),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "/login");
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(color: Colors.green.shade800, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


