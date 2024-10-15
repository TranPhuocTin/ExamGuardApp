
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../cubit/avatar_upload_cubit.dart';
import '../cubit/avatar_upload_state.dart';
import '../models/user_response.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';

class UserDetailView extends StatelessWidget {
  final User user;
  final VoidCallback onUserDeleted;
  final VoidCallback onUserUpdated;

  UserDetailView(
      {Key? key,
      required this.user,
      required this.onUserDeleted,
      required this.onUserUpdated})
      : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ssnController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _roleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state.deleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User deleted successfully')),
          );
        }
        if (state.updateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User updated successfully')),
          );
        }
        if (state.errorStudents != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student error: ${state.errorStudents}')),
          );
        } else if (state.errorTeachers != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Teacher error: ${state.errorTeachers}')),
          );
        }
        if (state.avatarUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Avatar updated successfully')),
          );
        }
      },
      builder: (context, state) {
        _initializeControllers();
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, state),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          icon: Icons.person,
                          title: 'Personal Information',
                          children: [
                            _buildTextFormField('Name', _usernameController,
                                enabled: state.isEditing),
                            _buildRoleDropdown(context, state),
                            _buildTextFormField('Email', _emailController,
                                enabled: state.isEditing),
                            _buildTextFormField('Phone', _phoneController,
                                enabled: state.isEditing),
                            _buildTextFormField('SSN', _ssnController,
                                enabled: state.isEditing),
                            _buildTextFormField('Address', _addressController,
                                enabled: state.isEditing),
                            _buildDatePicker(context, state),
                          ],
                        ),
                        SizedBox(height: 40),
                        _buildInfoCard(
                          icon: Icons.info_outline,
                          title: 'Additional Information',
                          children: [
                            _buildInfoRow('ID', user.id),
                            _buildInfoRow(
                                'Status', user.status?.toString() ?? ''),
                            _buildInfoRow(
                                'Created At', user.createdAt?.toString() ?? ''),
                            _buildInfoRow(
                                'Updated At', user.updatedAt?.toString() ?? ''),
                          ],
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: state.isEditing
              ? FloatingActionButton(
                  child: Icon(Icons.cancel),
                  backgroundColor: Colors.red,
                  onPressed: () {
                    context.read<UserCubit>().toggleEditing();
                    context
                        .read<UserCubit>()
                        .clearSelectedAvatar(user.role, user.id);
                    user.copyWith(
                        tempAvatarUrl: null, selectedAvatarFile: null);
                    print('image picked: ${user.tempAvatarUrl}');
                    _initializeControllers();
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserState state) {
    return SliverAppBar(
      backgroundColor: AppColors.primaryColor,
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildUserImageHeader(context, state),
      ),
      actions: [
        BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(state.isEditing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (state.isEditing) {
                  if (_formKey.currentState!.validate()) {
                    _showUpdateConfirmationDialog(context, state);
                  }
                } else {
                  context.read<UserCubit>().toggleEditing();
                }
              },
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmationDialog(context),
        ),
      ],
    );
  }

  Widget _buildUserImageHeader(BuildContext context, UserState userState) {
    return BlocBuilder<AvatarCubit, AvatarState>(
      builder: (context, avatarState) {
        return GestureDetector(
          onTap: userState.isEditing
              ? () async {
                  if (!userState.isUploading) {
                    print('Picking image...');
                    await context
                        .read<AvatarCubit>()
                        .pickImage(user.role, user.id);
                    final pickedImage =
                        context.read<AvatarCubit>().state.selectedImage;
                    if (pickedImage != null) {
                      print('Image picked: ${pickedImage.path}');
                      context.read<UserCubit>().setSelectedAvatar(
                            user.role,
                            user.id,
                            pickedImage,
                          );
                    } else {
                      print('No image picked');
                    }
                  }
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.cardLinearColor1,
                  AppColors.cardLinearColor2,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.7,
                  child: _getAvatarImage(context, userState),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'user-${user.id}',
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  _getAvatarImageProvider(context, userState),
                              backgroundColor: Colors.white,
                            ),
                            if (userState.isUploading)
                              CircularProgressIndicator(),
                            if (userState.isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        user.name ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getAvatarImage(BuildContext context, UserState userState) {
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      return Image.network(
        user.avatar!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return Image.asset('assets/images/avatar_2.jpg', fit: BoxFit.cover);
        },
      );
    } else {
      return Image.asset('assets/images/avatar_2.jpg', fit: BoxFit.cover);
    }
  }

  ImageProvider _getAvatarImageProvider(
      BuildContext context, UserState userState) {
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      return NetworkImage(user.avatar!);
    } else {
      return AssetImage('assets/images/avatar_2.jpg');
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[200],
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleDropdown(BuildContext context, UserState state) {
    final List<String> _roles = ['STUDENT', 'TEACHER'];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _roleController.text.isEmpty ? user.role : _roleController.text,
        decoration: InputDecoration(
          labelText: 'Role',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !state.isEditing,
          fillColor: state.isEditing ? null : Colors.grey[200],
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
        ),
        items: _roles.map((String role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: state.isEditing
            ? (String? newValue) {
                if (newValue != null) {
                  _roleController.text =
                      newValue; // Chỉ cập nhật khi có sự thay đổi
                }
              }
            : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Role cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, UserState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _dobController,
        enabled: state.isEditing,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !state.isEditing,
          fillColor: state.isEditing ? null : Colors.grey[200],
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: state.isEditing
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dobController.text.isNotEmpty
                      ? DateTime.parse(_dobController.text)
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  _dobController.text = formattedDate;
                }
              }
            : null,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  user.copyWith(tempAvatarUrl: null, selectedAvatarFile: null);
                  context.read<AvatarCubit>().clearSelectedImage(user.role, user.id);
                  Navigator.of(dialogContext).pop();
                }),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  // await context.read<UserCubit>().deleteUser(user.id, user.role);
                  onUserDeleted();
                } catch (e) {
                  print("Error deleting user: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting user")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateConfirmationDialog(BuildContext context, UserState state) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Update User'),
          content: Text('Are you sure you want to update this user?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context
                    .read<UserCubit>()
                    .clearSelectedAvatar(user.role, user.id);
                user.copyWith(tempAvatarUrl: null, selectedAvatarFile: null);
                context.read<AvatarCubit>().clearSelectedImage(user.role, user.id);
              },
            ),
            TextButton(
              child: Text('Yes', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await _updateUser(context, state);
                context
                    .read<UserCubit>()
                    .clearSelectedAvatar(user.role, user.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUser(BuildContext context, UserState state) async {
    print('Current user avatar: ${user.avatar}');

    final avatarFile = context.read<AvatarCubit>().state.selectedImage;
    String? avatarUrl;

    if (avatarFile != null) {
      avatarUrl = await context
          .read<UserCubit>()
          .uploadAvatar(user.role, user.id, avatarFile);
    }

    final updatedUser = user.copyWith(
      name: _usernameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      ssn: int.tryParse(_ssnController.text),
      address: _addressController.text,
      dob: DateTime.tryParse(_dobController.text),
      role: _roleController.text,
      updatedAt: DateTime.now(),
      avatar: avatarUrl ?? user.avatar,
    );

    await context.read<UserCubit>().updateUser(updatedUser).then((_) {
      onUserUpdated();
      context.read<UserCubit>().toggleEditing();
      context.read<AvatarCubit>().clearSelectedImage(user.role, user.id);
    });

    print('Updated user avatar: ${updatedUser.avatar}');
  }

  void _initializeControllers() {
    _usernameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone_number ?? '';
    _ssnController.text = user.ssn?.toString() ?? '';
    _addressController.text = user.address ?? '';
    _dobController.text =
        user.dob != null ? DateFormat('yyyy-MM-dd').format(user.dob!) : '';
    _roleController.text = user.role ?? ''; // Gán giá trị role từ user
  }
}
