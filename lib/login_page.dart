import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  void _handleLogin () {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните логин и пароль'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Поля заполнены'),
      ),
    );
  }


  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 100)),
              Text('Explore places in \n everyday life', textAlign: TextAlign.center,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26)),
              SizedBox(height: 27),
              TextField(
                controller: _loginController,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  fillColor: Colors.black,
                  filled: true,
                  hintText: 'Email or username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 18),

              TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  )
                ),
                obscureText: true,
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4)
                  )
                ),
                onPressed: _handleLogin,
                child: Text('Login')
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}