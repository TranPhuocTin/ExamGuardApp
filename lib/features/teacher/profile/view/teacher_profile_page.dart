import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view/base_profile_view.dart';
import '../../../login/cubit/auth_state.dart';
import '../../../splash/cubit/splash_screen_cubit.dart';

class TeacherProfile extends AbstractProfilePage {
  @override
  Widget buildExtraActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Handle admin settings
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Handle edit profile
          },
        ),
      ],
    );
  }

  @override
  AuthState getState(BuildContext context) {
    return context.watch<SplashScreenCubit>().state;
  }
}