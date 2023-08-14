import 'package:appdev/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'button.dart';
import 'text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password do not match!'),
        ),
      );
      return;
    }
    final authService = Provider.of<AuthServices>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_rounded,
                  size: 100,
                  color: Colors.blue[400],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'Lets create an account for you!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 18,
                ),
                MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obsecure: false),
                const SizedBox(
                  height: 12,
                ),
                MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obsecure: true),
                const SizedBox(
                  height: 12,
                ),
                MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obsecure: true),
                const SizedBox(
                  height: 12,
                ),
                MyButton(text: 'Register', onTap: signUp),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already registered?'),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Login now',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
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
