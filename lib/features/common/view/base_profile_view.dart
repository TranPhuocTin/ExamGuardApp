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
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Settings',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Account', [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'View profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('View Profile'),
                              backgroundColor: Colors.white,
                              elevation: 0,
                              iconTheme:
                                  const IconThemeData(color: Colors.black),
                            ),
                            body: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildProfileHeader(context, state),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                ]),
                _buildSection('Support & About', [
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Terms and Policies',
                    onTap: () {},
                  ),
                ]),
                _buildSection('Cache & cellular', [
                  _buildMenuItem(
                    icon: Icons.delete_outline,
                    title: 'Free up space',
                    onTap: () {},
                  ),
                ]),
                _buildSection(
                  'Actions',
                  [
                    _buildMenuItem(
                      icon: Icons.flag_outlined,
                      title: 'Report a problem',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Log out',
                      onTap: () async {
                        context.read<UserCubit>().resetState();
                        await context.read<AuthCubit>().logout(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 100,)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(state.user?.avatar ??
                  'https://cdn2.fptshop.com.vn/unsafe/Uploads/images/tin-tuc/175421/Originals/avatar-la-gi-2.jpg'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            state.user?.name ?? 'Unknown',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.user?.email ?? 'No email',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoGrid(context, state),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, AuthState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: state.user?.role ?? 'N/A',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: state.user?.phoneNumber ?? 'Not provided',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Birthday',
                  value: state.user?.dob != null
                      ? DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(state.user!.dob))
                      : 'Not provided',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member Since',
                  value: state.user?.createdAt != null
                      ? DateFormat('MMM yyyy')
                          .format(DateTime.parse(state.user!.createdAt))
                      : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: state.user?.address ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
