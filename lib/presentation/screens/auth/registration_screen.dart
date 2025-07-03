import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmind_ai/presentation/providers/app_state.dart';

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isLoading = ref.watch(_loadingProvider);
    final error = ref.watch(_errorProvider);

    Future<void> _register() async {
      ref.read(_loadingProvider.notifier).state = true;
      ref.read(_errorProvider.notifier).state = null;
      await Future.delayed(const Duration(seconds: 2));
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        ref.read(_errorProvider.notifier).state = 'All fields are required.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }
      if (!email.contains('@')) {
        ref.read(_errorProvider.notifier).state = 'Invalid email.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }
      if (password.length < 6) {
        ref.read(_errorProvider.notifier).state = 'Password too short.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }
      if (password != confirmPassword) {
        ref.read(_errorProvider.notifier).state = 'Passwords do not match.';
        ref.read(_loadingProvider.notifier).state = false;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);
      await prefs.setString('session_token', 'mock_token');
      ref.read(appStateProvider).login();
      ref.read(_loadingProvider.notifier).state = false;
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (error != null) ...[Text(error, style: const TextStyle(color: Colors.red)), const SizedBox(height: 12)],
            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child: isLoading ? const CircularProgressIndicator() : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

final _loadingProvider = StateProvider<bool>((ref) => false);
final _errorProvider = StateProvider<String?>((ref) => null);
