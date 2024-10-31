import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../configs/app_colors.dart';
import '../../login/cubit/auth_state.dart';
import '../../login/cubit/auth_cubit.dart';
import '../../admin/cubit/user_cubit.dart';
import 'package:intl/intl.dart';

abstract class AbstractProfilePage extends StatelessWidget {
  const AbstractProfilePage({Key? key}) : super(key: key);

  // Abstract method để các lớp con override
  Widget buildExtraActions(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, state),
                const SizedBox(height: 20),
                _buildProfileInfo(context, state),
                _buildLogoutButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30,),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              state.user?.avatar ??
                  'https://cdn2.fptshop.com.vn/unsafe/Uploads/images/tin-tuc/175421/Originals/avatar-la-gi-2.jpg',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.user?.name ?? '',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          Text(
            state.user?.email ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, AuthState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 20),
          ProfileInfoItem(
            icon: Icons.school,
            label: 'Role',
            value: state.user?.role ?? '',
          ),
          if (state.user?.phoneNumber != null)
            ProfileInfoItem(
              icon: Icons.phone,
              label: 'Phone',
              value: state.user!.phoneNumber,
            ),
          if (state.user?.address != null)
            ProfileInfoItem(
              icon: Icons.location_on,
              label: 'Address',
              value: state.user!.address,
            ),
          ProfileInfoItem(
            icon: Icons.email,
            label: 'Email',
            value: state.user?.email ?? '',
          ),
          if (state.user?.gender != null)
            ProfileInfoItem(
              icon: Icons.person,
              label: 'Gender',
              value: state.user!.gender,
            ),
          if (state.user?.createdAt != null)
            ProfileInfoItem(
              icon: Icons.access_time,
              label: 'Member Since',
              value: DateFormat('MMMM d, y')
                  .format(DateTime.parse(state.user!.createdAt)),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () async {
          context.read<UserCubit>().resetState();
          await context.read<AuthCubit>().logout();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (Route<dynamic> route) => false,
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
