
import 'package:exam_guardian/features/admin/view/user_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/user_repository.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';
import '../cubit/user_cubit.dart';
class UserDetailScreen2 extends StatelessWidget {
  final User user;
  final VoidCallback onUserDeleted;
  const UserDetailScreen2({super.key, required this.user, required this.onUserDeleted});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(context.read<UserRepository>()),
      child: UserDetailView(user: user, onUserDeleted: onUserDeleted,),
    );
  }
}