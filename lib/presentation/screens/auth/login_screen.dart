import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmind_ai/presentation/providers/app_state.dart';
import 'package:taskmind_ai/presentation/screens/auth/registration_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final isLoading = ref.watch(_loadingProvider);
    final error = ref.watch(_errorProvider);

    Future<void> _login() async {
      ref.read(_loadingProvider.notifier).state = true;
      ref.read(_errorProvider.notifier).state = null;

      await Future.delayed(const Duration(seconds: 2));

      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ref.read(_errorProvider.notifier).state = 'All fields are required.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('user_email');
      final storedPassword = prefs.getString('user_password');

      if (storedEmail == null || storedPassword == null) {
        ref.read(_errorProvider.notifier).state = 'No account found. Please register first.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }

      if (email != storedEmail || password != storedPassword) {
        ref.read(_errorProvider.notifier).state = 'Invalid email or password.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }

      await prefs.setString('session_token', 'mock_token');
      ref.read(appStateProvider).login();
      ref.read(_loadingProvider.notifier).state = false;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (error != null) ...[Text(error, style: const TextStyle(color: Colors.red)), const SizedBox(height: 12)],
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading ? const CircularProgressIndicator() : const Text('Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed:
                  isLoading
                      ? null
                      : () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegistrationScreen()));
                      },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}

final _loadingProvider = StateProvider<bool>((ref) => false);
final _errorProvider = StateProvider<String?>((ref) => null);
