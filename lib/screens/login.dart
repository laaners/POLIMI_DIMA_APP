import 'package:dima_app/firebase_cruds_testing.dart';
import 'package:dima_app/screens/password_reset.dart';
import 'package:dima_app/screens/signup.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // todo: remove appBar
      body: ResponsiveWrapper(
        child: LogInForm(),
      ),
    );
  }
}

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextButton(
          key: GlobalKey(debugLabel: 'test1'),
          onPressed: () async {
            LoadingOverlay.show(context);
            FirebaseCrudsTesting.signUpNewUsers(context);
            LoadingOverlay.hide(context);
          },
          child: const Text("Create some users"),
        ),
        TextButton(
          key: GlobalKey(debugLabel: 'test1'),
          onPressed: () async {
            LoadingOverlay.show(context);
            await Provider.of<FirebaseUser>(context, listen: false)
                .logInWithUsername(
              context: context,
              username: "UsernameId0jjhjl",
              password: "password",
            );
            LoadingOverlay.hide(context);
          },
          child: const Text("Firebase login"),
        ),
        const SizedBox(
          height: 50,
        ),
        SizedBox(
          height: 170,
          child: Image.asset('images/logo.png'),
        ),
        Text(
          "Eventy",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(
          height: 50,
        ),
        Text(
          "Log In",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.face, color: Colors.grey),
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                ),
                validator: (value) {
                  // todo: check if username already exists
                  if (value == null || value.isEmpty) {
                    return 'Enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _passwordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.grey),
                  hintText: 'Password',
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  }
                  return null;
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PasswordResetScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              MyButton(
                text: "LOG IN",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    await Provider.of<FirebaseUser>(context, listen: false)
                        .logInWithUsername(
                      context: context,
                      username: _usernameController.text,
                      password: _passwordController.text,
                    );
                  }
                },
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextButton(
                      key: const Key("log-in-to-sign-up-screen"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
