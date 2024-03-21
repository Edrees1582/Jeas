import 'package:flutter/material.dart';
import 'package:jeas/models/custom_user.dart';
import 'package:jeas/screens/login_screen.dart';
import 'package:jeas/screens/requests_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);

    if (user == null) {
      return const LoginScreen();
    } else {
      return RequestsScreen();
    }
  }
}
