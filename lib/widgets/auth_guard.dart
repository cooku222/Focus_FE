import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  Future<bool> _isUserLoggedIn() async {
    const storage = FlutterSecureStorage();
    try {
      String? token = await storage.read(key: 'accessToken');
      if (token == null || token.isEmpty) {
        return false;
      }
      // Additional validation logic for the token if needed
      return true;
    } catch (e) {
      print("Error checking login status: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data == true) {
            // User is logged in, render the protected screen
            return child;
          } else {
            // User is not logged in, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
          }
        }

        // Default case to avoid rendering while redirecting
        return const SizedBox();
      },
    );
  }
}
