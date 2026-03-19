import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signInAsGuest() async {
    setState(() {
      _isLoading = true;
    });
    final userCredential = await _authService.signInAsGuest();
    setState(() {
      _isLoading = false;
    });
    if (userCredential != null) {
      context.go('/home');
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    final userCredential = await _authService.signInWithGoogle();
    setState(() {
      _isLoading = false;
    });
    if (userCredential != null) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: const Text('Login with Google'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signInAsGuest,
                    child: const Text('Play as Guest'),
                  ),
                ],
              ),
      ),
    );
  }
}
