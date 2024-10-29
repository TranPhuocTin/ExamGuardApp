import 'package:exam_guardian/features/admin/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
      ),
      body: SafeArea(
        child: Center(
          child: TextButton(
            onPressed: () async {
              context.read<UserCubit>().resetState();
              await context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Route name của màn hình login
                (Route<dynamic> route) =>
                    false, // Xóa hết stack của các màn hình trước đó
              );
            },
            child: Text('Sign out'),
          ),
        ),
      ),
    );
  }
}
