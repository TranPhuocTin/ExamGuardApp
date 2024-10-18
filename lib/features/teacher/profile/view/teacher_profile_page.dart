import 'package:exam_guardian/features/admin/models/user_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_colors.dart';
import '../../../admin/cubit/user_cubit.dart';
import '../../../login/cubit/auth_cubit.dart';


class TeacherProfilePage extends StatelessWidget {
  final User teacher; // Assume we have a Teacher model

  const TeacherProfilePage({Key? key, required this.teacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileInfo(),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.primaryColor,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(teacher.avatar!),
          ),
          SizedBox(height: 16),
          Text(
            teacher.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            teacher.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ProfileInfoItem(icon: Icons.school, label: 'Subject', value: teacher.role),
          ProfileInfoItem(icon: Icons.phone, label: 'Phone', value: teacher.phone_number!),
          ProfileInfoItem(icon: Icons.location_on, label: 'Address', value: teacher.address!),
          // Add more ProfileInfoItem widgets for additional information
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: ElevatedButton(
        onPressed: () async {

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',  // Route name của màn hình login
                (Route<dynamic> route) => false, // Xóa hết stack của các màn hình trước đó
          );
          context.read<UserCubit>().resetState();
          await context.read<AuthCubit>().logout();
        },
        child: Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: Size(double.infinity, 50),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}
