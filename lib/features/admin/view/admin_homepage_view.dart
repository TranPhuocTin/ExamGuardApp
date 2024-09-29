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
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<UserCubit>().fetchUsers(_getCurrentRole());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final userState = context.read<UserCubit>().state;
    if (_isBottom && !userState.isLoading && !userState.isLoadingMore && !userState.hasReachedMax) {
      print('Reached bottom, loading more');
      print('Current page before load more: ${userState.currentPage}');
      print('Has reached max before load more: ${userState.hasReachedMax}');

      context.read<UserCubit>().fetchUsers(
        _getCurrentRole(),
        page: userState.currentPage + 1,
      );
    }
  }


  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  String _getCurrentRole() {
    return _tabController.index == 0 ? 'TEACHER' : 'STUDENT';
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
                  onTap: (_) {
                    context.read<UserCubit>().resetState();
                    _loadInitialData();
                  },
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
                    _buildUserList(),
                    _buildUserList(),
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

  Widget _buildUserList() {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        print('Building user list');
        print('Users count: ${state.users.length}');
        print('Is loading: ${state.isLoading}');
        print('Is loading more: ${state.isLoadingMore}');
        print('Has reached max: ${state.hasReachedMax}');

        if (state.users.isEmpty && state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.users.isEmpty && state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: state.users.length + 1, // Luôn thêm 1 item ở cuối
          itemBuilder: (context, index) {
            if (index >= state.users.length) {
              if (state.isLoadingMore) {
                return Center(child: CircularProgressIndicator());
              } else if (state.hasReachedMax) {
                return _buildEndOfListMessage();
              } else {
                return SizedBox.shrink(); // Khoảng trống nếu chưa tải hết và không đang tải
              }
            }
            print('Rendering user at index: $index');
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UserDetailScreen(user: state.users[index]),
                ));
              },
              child: _buildUserCard(state.users[index]),
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
              //Dang set cung avatar
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
            "Đã tải hết dữ liệu",
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

