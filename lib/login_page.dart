import 'package:appdev/auth_services.dart';
import 'package:appdev/button.dart';
import 'package:appdev/text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    try {
      await authService.signInWithEmailAndPassword(
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
                  'Welcome back you have been missed',
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
                MyButton(text: 'Login', onTap: signIn),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
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
