import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.5),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  Email
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscureText = !obscureText),
                        icon: Icon(
                          obscureText ? Icons.remove_red_eye : Icons.lock,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    obscureText: obscureText,
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* required';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) => validate(),
                  ),
                  const SizedBox(height: 12),

                  // Button
                  ElevatedButton(
                    onPressed: () => validate(),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 12),

                  // Sign Up
                  RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account?\t\t',
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const SignUp())),
                          style: const TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  validate() async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message!)));
      }
    }
  }
}
