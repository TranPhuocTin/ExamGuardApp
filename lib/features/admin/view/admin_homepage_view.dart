// import 'package:exam_guardian/utils/app_colors.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:exam_guardian/features/admin/view/user_detail_view.dart';
// import '../../../utils/text_style.dart';
//
// class AdminMainScreen extends StatefulWidget {
//   const AdminMainScreen({super.key});
//
//   @override
//   State<AdminMainScreen> createState() => _AdminMainScreenState();
// }
//
// class _AdminMainScreenState extends State<AdminMainScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final Map<String, dynamic> dummyUserData = {
//     'id': 1,
//     'username': 'phanvanduc',
//     'password': 'hashedpassword123',
//     // Trong thực tế, không nên lưu trữ mật khẩu như thế này
//     'role': 'Teacher',
//     'name': 'Phan Văn Đức',
//     'email': 'phanvanduc@example.com',
//     'phone_number': '0123456789',
//     'avatar': 'https://example.com/avatars/phanvanduc.jpg',
//     'gender': 'Male',
//     'birth_date': '1985-05-15',
//     'address': '123 Đường Lê Lợi, Quận 1, TP.HCM',
//     'subject': 'Mathematics',
//     'class': '10A1',
//     'status': 'Active',
//     'bio': 'Giáo viên toán với 10 năm kinh nghiệm giảng dạy.',
//     'createdAt': '2023-01-01T08:00:00Z',
//     'updatedAt': '2024-09-15T14:30:00Z',
//     'last_login': '2024-09-27T09:45:00Z',
//     'teaching_hours': 120,
//     'rating': 4.8,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _tabController.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Image.asset('assets/icons/exam_guard_logo.png'),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushNamed(context, '/admin_profile_screen');
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(width: 1, color: Colors.grey)),
//                       child: CircleAvatar(
//                         radius: 20,
//                         backgroundImage:
//                             AssetImage('assets/images/teacher_avatar.png'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: TabBar(
//                   dividerHeight: 0,
//                   tabAlignment: TabAlignment.start,
//                   controller: _tabController,
//                   labelColor: AppColors.primaryColor,
//                   unselectedLabelColor: Colors.black54,
//                   indicatorColor: AppColors.primaryColor,
//                   isScrollable: true,
//                   tabs: [
//                     Tab(text: 'Teacher'),
//                     Tab(text: 'Student'),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                 child: Row(
//                   children: [
//                     Flexible(
//                       child: CupertinoSearchTextField(),
//                     ),
//                     IconButton(onPressed: () {}, icon: Icon(Icons.sort))
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     _buildManageList(), // Teacher tab
//                     _buildManageList(), // Student tab
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildManageList() {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: 10,
//             scrollDirection: Axis.vertical,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   // Navigator.of(context).push(MaterialPageRoute(
//                   //   builder: (context) => UserDetailScreen(user: dummyUserData),
//                   // ));
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 16),
//                   child: Container(
//                     height: 90,
//                     width: 300,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF303333), Color(0xFF75A7A1)],
//                         // Bắt đầu và kết thúc màu gradient
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                       ),
//                       borderRadius:
//                           BorderRadius.circular(10), // Bo góc cho Card
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Image.asset(
//                                     'assets/icons/id-card.png',
//                                     width: 30,
//                                     height: 30,
//                                     color: Colors.white,
//                                   ),
//                                   Text(
//                                     '01',
//                                     style: TextStyles.bodyMedium
//                                         .copyWith(color: Colors.white),
//                                   )
//                                 ],
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Image.asset(
//                                         'assets/icons/name.png',
//                                         width: 30,
//                                         height: 30,
//                                         color: Colors.white,
//                                       ),
//                                       Text(
//                                         'Trần Hà My',
//                                         style: TextStyles.bodyLarge
//                                             .copyWith(color: Colors.white),
//                                       )
//                                     ],
//                                   ),
//                                   Row(
//                                     children: [
//                                       Icon(
//                                         Icons.female,
//                                         size: 30,
//                                         color: Colors.pink,
//                                       ),
//                                       Text(
//                                         'Female',
//                                         style: TextStyles.bodyLarge
//                                             .copyWith(color: Colors.white),
//                                       )
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(right: 10),
//                                 child: CircleAvatar(
//                                   backgroundImage: AssetImage(
//                                       'assets/images/teacher_avatar.png'),
//                                   radius: 30,
//                                 ),
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'package:exam_guardian/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:exam_guardian/features/admin/view/user_detail_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/text_style.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<UserCubit>().fetchUsers(_tabController.index == 0 ? 'TEACHER' : 'STUDENT');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/icons/exam_guard_logo.png'),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_profile_screen');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                        AssetImage('assets/images/teacher_avatar.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  dividerHeight: 0,
                  tabAlignment: TabAlignment.start,
                  controller: _tabController,
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: AppColors.primaryColor,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Teacher'),
                    Tab(text: 'Student'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  children: [
                    Flexible(
                      child: CupertinoSearchTextField(),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.sort))
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildManageList('TEACHER'),
                    _buildManageList('STUDENT'),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageList(String role) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.users.isEmpty && state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.users.isEmpty && state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: state.users.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.users.length) {
              return Center(child: CircularProgressIndicator());
            }
            final user = state.users[index];
            return GestureDetector(
              onTap: () {
                // Navigator.of(context).push(MaterialPageRoute(
                //   builder: (context) => UserDetailScreen(user: user),
                // ));
              },
              child: _buildUserCard(user),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        height: 90,
        width: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF303333), Color(0xFF75A7A1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/id-card.png',
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                      Text(
                        user.id,
                        style: TextStyles.bodyMedium.copyWith(color: Colors.white),
                      )
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/name.png',
                            width: 30,
                            height: 30,
                            color: Colors.white,
                          ),
                          Text(
                            user.name,
                            style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            user.gender == 'Female' ? Icons.female : Icons.male,
                            size: 30,
                            color: user.gender == 'Female' ? Colors.pink : Colors.blue,
                          ),
                          Text(
                            user.gender!,
                            style: TextStyles.bodyLarge.copyWith(color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(user.avatar ?? 'https://via.placeholder.com/150'),
                radius: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
