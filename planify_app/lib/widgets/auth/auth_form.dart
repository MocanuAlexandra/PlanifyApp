import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../other/square_tile_buttons.dart';

enum AuthMode { signUp, login }

class AuthForm extends StatefulWidget {
  final void Function(
      String email, String password, bool isLogin, BuildContext ctx) submitFn;
  final void Function(BuildContext ctx) googleSignIn;
  final bool isLoading;

  const AuthForm(
      {super.key,
      required this.submitFn,
      required this.isLoading,
      required this.googleSignIn});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final _passwordNode = FocusNode();
  String? userEmail;
  String? userPass;
  final String _passwordRegexPattern =
      "(?:(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#%^&+=]).*)[^\\s]{8,}";
  final _passwordController = TextEditingController();
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  // we need this for animating the switch between login and sign up
  // and to display the confirm password field in sign up mode
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeIn,
      ),
    );
  }

  // switch between login and sign up
  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller!.forward();
      _formKey.currentState!.reset();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller!.reverse();
      _formKey.currentState!.reset();
    }
  }

  // validate and submit the form
  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    // check if the form is valid,
    // if it is, save and pass the fields to the submit function
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(userEmail!.trim(), userPass!.trim(),
          _authMode == AuthMode.login, context);
    }
  }

  // login with google credentials
  void _trySignInWithGoogle() {
    widget.googleSignIn(context);
  }

  //auxiliary methods
  AnimatedContainer confirmPasswordField() {
    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: _authMode == AuthMode.signUp ? 60 : 0,
        maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      child: FadeTransition(
        opacity: _opacityAnimation!,
        child: SlideTransition(
          position: _slideAnimation!,
          child: FormBuilderTextField(
              name: 'confirmPassword',
              enabled: _authMode == AuthMode.signUp,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: IconButton(
                  icon: Icon(_confirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_confirmPasswordVisible,
              validator: _authMode == AuthMode.signUp
                  ? FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Required'),
                      FormBuilderValidators.match(_passwordController.text,
                          errorText: 'Passwords do not match'),
                    ])
                  : null),
        ),
      ),
    );
  }

  FormBuilderTextField passwordField() {
    return FormBuilderTextField(
        name: 'password',
        focusNode: _passwordNode,
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
                _passwordVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        obscureText: !_passwordVisible,
        textInputAction: TextInputAction.next,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: 'Required'),
          FormBuilderValidators.match(_passwordRegexPattern, errorText: '''
Use at least one lower case character, 
one upper case character and one digit, 
one special character (?=.*[@#%^&+=]), 
least 8 characters and no space.'''),
        ]),
        onSaved: (newValue) => {
              userPass = newValue,
            });
  }

  FormBuilderTextField emailField(BuildContext context) {
    return FormBuilderTextField(
        name: 'email',
        decoration: const InputDecoration(labelText: 'Email Address'),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: 'Required'),
          FormBuilderValidators.email(errorText: 'Invalid email address'),
        ]),
        onSubmitted: (value) =>
            {FocusScope.of(context).requestFocus(_passwordNode)},
        onSaved: (newValue) => {
              userEmail = newValue,
            });
  }

  @override
  void dispose() {
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      margin: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.signUp ? 440 : 370,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signUp ? 440 : 370),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              // email field
              emailField(context),
              // password field
              passwordField(),
              // if the form is in sign up mode, display the confirm password field
              confirmPasswordField(),
              const SizedBox(
                height: 20,
              ),
              // if the request is being handled, display circular indicator
              if (widget.isLoading) const CircularProgressIndicator(),
              // else display the submit button with login/sign up
              if (!widget.isLoading)
                ElevatedButton(
                  onPressed: _trySubmit,
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                  ),
                  child: Text(
                    _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                  ),
                ),
              //change the form to be for sign up/login
              if (!widget.isLoading)
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 4),
                  ),
                  onPressed: _switchAuthMode,
                  child: Text(
                    _authMode == AuthMode.login
                        ? 'Create a new account'
                        : 'I already have an account',
                  ),
                ),
              if (!widget.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Or continue with'),
                ),
              //sign in with google
              if (!widget.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SquareTile(
                    imagePath: 'assets/images/google.jpg',
                    onTap: _trySignInWithGoogle,
                  ),
                )
            ]),
          ),
        ),
      ),
    );
  }
}
