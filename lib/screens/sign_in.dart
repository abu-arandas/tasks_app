import 'package:flutter/material.dart';

import '/controller/authentication.dart';

import '/screens/sign_up.dart';

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
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Image
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset('assets/sign_in.png'),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  //  Email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
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
                  ),

                  // Password
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
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
                  ),

                  // Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () => validate(),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(500, 50),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ),

                  // Sign Up
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUp()),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 17,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      );

  validate() {
    if (formKey.currentState!.validate()) {
      Authentication.instance.signIn(context: context, email: emailController.text, password: passwordController.text);
    }
  }
}
