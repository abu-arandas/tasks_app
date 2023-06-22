import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tasks_app/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
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
                  // Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'First Name'),
                          controller: firstNameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '* required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Last Name'),
                          controller: lastNameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '* required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) => validate(),
                  ),
                  const SizedBox(height: 12),

                  // Button
                  ElevatedButton(
                    onPressed: () => validate(),
                    child: const Text('Sign Up'),
                  ),
                  const SizedBox(height: 12),

                  // Sign In
                  RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account?\t\t',
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const SignIn())),
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
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        await FirebaseAuth.instance.currentUser!
            .updateDisplayName('${firstNameController.text} ${lastNameController.text}');
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message!)));
      }
    }
  }
}
