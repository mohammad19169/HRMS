import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedRole = 'applicant';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

Future<void> loginUser() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    // 1) Sign in first
    UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    User user = cred.user!;
    await user.reload();

    // 2) Now read Firestore doc by UID
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snap.exists) {
      await FirebaseAuth.instance.signOut();
      _showSnackBar('User not found', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final role = snap['role'];

    // 3) Check email verification only for applicant
    if (role == 'applicant' && !user.emailVerified) {
      await FirebaseAuth.instance.signOut();
      _showSnackBar('Please verify your email.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // 4) Validate role
    if (_selectedRole != role) {
      await FirebaseAuth.instance.signOut();
      _showSnackBar('Only $role can login here', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // 5) Navigate
    switch (role) {
      case 'hr':
        Navigator.pushReplacementNamed(context, '/hrDashboard');
        break;
      case 'employee':
        Navigator.pushReplacementNamed(context, '/employeeDashboard');
        break;
      case 'applicant':
        Navigator.pushReplacementNamed(context, '/applicantDashboard');
        break;
      case 'ceo':
        Navigator.pushReplacementNamed(context, '/ceoDashboard');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/adminDashboard');
        break;
      case 'pm':
      case 'projectmanager':
        Navigator.pushReplacementNamed(context, '/pmDashboard');
        break;
      default:
        await FirebaseAuth.instance.signOut();
        _showSnackBar('Unknown role', isError: true);
    }
  } on FirebaseAuthException catch (e) {
    _showSnackBar(e.message ?? 'Login failed', isError: true);
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.cyan.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.cyan.shade50,
              Colors.cyan.shade100,
              Colors.cyan.shade50,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.cyan.shade200,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.cyan.shade100],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan.shade600,
                                  Colors.cyan.shade800,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.business, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to your account",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Login As',
                              prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.cyan.shade100,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'projectmanager', child: Text('Project Manager')),
                              DropdownMenuItem(value: 'hr', child: Text('HR')),
                              DropdownMenuItem(value: 'employee', child: Text('Employee')),
                              DropdownMenuItem(value: 'ceo', child: Text('CEO')),
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              DropdownMenuItem(value: 'applicant', child: Text('Applicant')),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedRole = value);
                            },
                            validator: (value) => value == null || value.isEmpty ? 'Please select a role' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.cyan.shade100,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your password';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.cyan.shade600,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.cyan.shade100,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Sign In",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(
                                color: Colors.cyan.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
