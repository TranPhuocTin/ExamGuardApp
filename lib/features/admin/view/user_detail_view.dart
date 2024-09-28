// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:exam_guardian/utils/app_colors.dart';
//
// class UserDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> user;
//
//   const UserDetailScreen({Key? key, required this.user}) : super(key: key);
//
//   @override
//   _UserDetailScreenState createState() => _UserDetailScreenState();
// }
//
// class _UserDetailScreenState extends State<UserDetailScreen> {
//   late TextEditingController _usernameController;
//   late TextEditingController _roleController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   bool _isEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _usernameController = TextEditingController(text: widget.user['username']);
//     _roleController = TextEditingController(text: widget.user['role']);
//     _emailController = TextEditingController(text: widget.user['email']);
//     _phoneController = TextEditingController(text: widget.user['phone_number']);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Hero(
//                 tag: 'user-${widget.user['id']}',
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topRight,
//                       end: Alignment.bottomLeft,
//                       colors: [AppColors.cardLinearColor1, AppColors.cardLinearColor2],
//                     ),
//                   ),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Opacity(
//                         opacity: 0.7,
//                         child: Image.asset('assets/images/teacher_avatar.png', fit: BoxFit.cover),
//                       ),
//                       // Positioned(
//                       //   bottom: 60,
//                       //   right: 16,
//                       //   child: CircleAvatar(
//                       //     radius: 50,
//                       //     backgroundImage: AssetImage('assets/images/teacher_avatar.png'),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             actions: [
//               // Edit/Save button
//               IconButton(
//                 icon: Icon(_isEditing ? Icons.save : Icons.edit),
//                 onPressed: () {
//                   setState(() {
//                     if (_isEditing) {
//                       // Save logic here
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Changes saved successfully')),
//                       );
//                     }
//                     _isEditing = !_isEditing;
//                   });
//                 },
//               ),
//               // Delete button
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.red),
//                 onPressed: () async {
//                   // Show a confirmation dialog before deleting the user
//                   bool? confirmed = await showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text('Delete User'),
//                         content: Text('Are you sure you want to delete this user?'),
//                         actions: [
//                           TextButton(
//                             child: Text('Cancel'),
//                             onPressed: () {
//                               Navigator.of(context).pop(false); // Dismiss and return false
//                             },
//                           ),
//                           TextButton(
//                             child: Text('Delete', style: TextStyle(color: Colors.red)),
//                             onPressed: () {
//                               Navigator.of(context).pop(true); // Dismiss and return true
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   );
//
//                   if (confirmed == true) {
//                     // Perform the delete logic here
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('User deleted successfully')),
//                     );
//
//                     // Optionally, navigate back to the previous screen after deleting the user
//                     Navigator.of(context).pop();
//                   }
//                 },
//               ),
//             ],
//           ),
//
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInfoCard(
//                     icon: Icons.person,
//                     title: 'Personal Information',
//                     children: [
//                       _buildTextField('Username', _usernameController, enabled: false),
//                       _buildTextField('Role', _roleController, enabled: _isEditing),
//                       _buildTextField('Email', _emailController, enabled: _isEditing),
//                       _buildTextField('Phone', _phoneController, enabled: _isEditing),
//                     ],
//                   ),
//                   SizedBox(height: 40),
//                   _buildInfoCard(
//                     icon: Icons.info_outline,
//                     title: 'Additional Information',
//                     children: [
//                       _buildInfoRow('ID', widget.user['id'].toString()),
//                       _buildInfoRow('Status', widget.user['status']),
//                       _buildInfoRow('Created At', widget.user['createdAt']),
//                       _buildInfoRow('Updated At', widget.user['updatedAt']),
//                     ],
//                   ),
//                   SizedBox(height: 50),
//                 ],
//               ),
//             ),
//           ),
//           // SliverToBoxAdapter(child: Container(height: 95,),)
//         ],
//       ),
//       floatingActionButton: _isEditing
//           ? FloatingActionButton(
//         child: Icon(Icons.cancel),
//         backgroundColor: Colors.red,
//         onPressed: () {
//           setState(() {
//             _isEditing = false;
//             // Reset controllers to original values
//             _emailController.text = widget.user['email'];
//             _phoneController.text = widget.user['phone_number'];
//           });
//         },
//       )
//           : null,
//     );
//   }
//
//   Widget _buildInfoCard({required IconData icon, required String title, required List<Widget> children}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: AppColors.primaryColor),
//                 SizedBox(width: 8),
//                 Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             Divider(),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//           filled: !enabled,
//           fillColor: enabled ? null : Colors.grey[200],
//           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor)))
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
//           Text(value),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _roleController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
// }