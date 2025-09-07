import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whms/features/login/views/login_info_view.dart';
import 'package:whms/features/login/views/login_view.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Row(
        children: [
          Expanded(flex: 2, child: LoginInfoView()),
          Expanded(flex: 1, child: LoginView())
        ],
      ),
    );
  }
}
