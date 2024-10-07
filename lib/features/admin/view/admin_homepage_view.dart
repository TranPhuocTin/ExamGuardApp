import 'dart:async';

import 'package:exam_guardian/data/user_repository.dart';
import 'package:exam_guardian/features/admin/view/user_detail_page.dart';
import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
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
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;
  bool _isDataPreloaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollControllers.forEach(
            (controller) => controller.addListener(() => _onScroll(controller)));
    _searchController.addListener(_onSearchChanged);
    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      await context.read<UserCubit>().preloadData();
      print("Teachers after preloadData: ${context.read<UserCubit>().state.teachers}");
      print("Students after preloadData: ${context.read<UserCubit>().state.students}");
      setState(() {
        _isDataPreloaded = true;
      });
    } catch (e) {
      print("Error in preloadData: $e");
      // Xử lý lỗi
    }
  }

  void _handleTabChange() async {
    if (_tabController.indexIsChanging) {
      await _loadDataForCurrentTab();
    }
  }


  Future<void> _loadDataForCurrentTab() async {
    if (_isSearching) {
      await context.read<UserCubit>().searchUsers(_searchController.text, _getCurrentRole());
    } else {
      await context.read<UserCubit>().fetchUsers(_getCurrentRole());
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      if (_searchController.text.isNotEmpty) {
        _isSearching = true;
        await context.read<UserCubit>().searchUsers(_searchController.text, _getCurrentRole());
      } else {
        _clearSearch();
      }
    });
  }

  void _clearSearch() async {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
      });
      FocusScope.of(context).unfocus();
      await context.read<UserCubit>().fetchUsers(_getCurrentRole());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllers.forEach((controller) => controller.dispose());
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll(ScrollController controller) {
    if (_isBottom(controller)) {
      final userState = context.read<UserCubit>().state;
      final isTeacher = _getCurrentRole() == 'TEACHER';
      final isLoading = isTeacher ? userState.isLoadingTeachers : userState.isLoadingStudents;
      final isLoadingMore = isTeacher ? userState.isLoadingMoreTeachers : userState.isLoadingMoreStudents;
      final hasReachedMax = isTeacher ? userState.hasReachedMaxTeachers : userState.hasReachedMaxStudents;
      final currentPage = isTeacher ? userState.currentPageTeachers : userState.currentPageStudents;

      if (!isLoading && !isLoadingMore && !hasReachedMax) {
        if (_isSearching) {
          context.read<UserCubit>().searchUsers(
            _searchController.text,
            _getCurrentRole(),
            page: currentPage + 1,
          );
        } else {
          context.read<UserCubit>().fetchUsers(
            _getCurrentRole(),
            page: currentPage + 1,
          );
        }
      }
    }
  }

  bool _isBottom(ScrollController controller) {
    if (!controller.hasClients) return false;
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String _getCurrentRole() {
    return _tabController.index == 0 ? 'TEACHER' : 'STUDENT';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listenWhen: (previous, current) => previous.deleteSuccess != current.deleteSuccess,
      listener: (context, state) async {
        if (state.deleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User deleted successfully')),
          );
          final students = context.read<UserCubit>().state.students;
          // Refresh the current tab data
          await _loadDataForCurrentTab();
          final studentsAfterDeleted = context.read<UserCubit>().state.students;
        }
      },
      child: Scaffold(
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
                    onTap: (_) {
                      _loadDataForCurrentTab();
                    },
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Row(
                    children: [
                      Flexible(
                        child: CupertinoSearchTextField(
                          controller: _searchController,
                          onChanged: (value) {
                            _onSearchChanged();
                          },
                          onSuffixTap: _clearSearch,
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: Icon(Icons.sort))
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: _isDataPreloaded
                      ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserList(0),
                      _buildUserList(1),
                    ],
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(int tabIndex) {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) => previous.students != current.students || previous.teachers != current.teachers,
      builder: (context, state) {
        final users = tabIndex == 0 ? state.teachers : state.students;
        final isLoading = tabIndex == 0 ? state.isLoadingTeachers : state.isLoadingStudents;
        final isLoadingMore = tabIndex == 0 ? state.isLoadingMoreTeachers : state.isLoadingMoreStudents;
        final hasReachedMax = tabIndex == 0 ? state.hasReachedMaxTeachers : state.hasReachedMaxStudents;

        if (isLoading && users.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (users.isEmpty) {
          return Center(child: Text("No users found."));
        }

        return ListView.builder(
          controller: _scrollControllers[tabIndex],
          itemCount: users.length + (isLoadingMore || !hasReachedMax ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < users.length) {
              return KeyedSubtree(
                key: ValueKey(users[index].id),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserDetailScreen2(
                        user: users[index],
                        onUserDeleted: () async {
                          await context.read<UserCubit>().deleteUser(users[index].id, _getCurrentRole()).then((_) async {
                            Navigator.of(context).pop();
                            context.read<UserCubit>().fetchUsers(_getCurrentRole(), forceRefresh: true);
                          });
                        }
                      ),
                    ));
                  },
                  child: _buildUserCard(users[index]),
                ),
              );
            } else {
              if (isLoadingMore) {
                return Center(child: CircularProgressIndicator());
              } else if (!hasReachedMax) {
                return _buildEndOfListMessage();
              } else {
                return SizedBox.shrink();
              }
            }
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
                            style: TextStyles.bodyLarge
                                .copyWith(color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            user.gender == 'FEMALE' ? Icons.female : Icons.male,
                            size: 28,
                            color: user.gender == 'FEMALE'
                                ? Colors.red
                                : Colors.blue,
                          ),
                          Text(
                            user.gender!,
                            style: TextStyles.bodyLarge
                                .copyWith(color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://img.tripi.vn/cdn-cgi/image/width=700,height=700/https://gcs.tripi.vn/public-tripi/tripi-feed/img/474015QSt/anh-gai-xinh-1.jpg'),
                radius: 30,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfListMessage() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 30),
          SizedBox(height: 8),
          Text(
            "You're all caught up!\nNo more data to load",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
