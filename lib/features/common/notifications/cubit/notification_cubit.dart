import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/notification_state.dart';
import '../../models/notification.dart';
import '../../../../data/noti_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';

class NotificationListCubit extends Cubit<NotificationState> {
  final NotiRepository _notiRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;

  NotificationListCubit(
    this._notiRepository,
    this._tokenStorage,
    this._tokenCubit,
  ) : super(const NotificationState());

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        emit(state.copyWith(
          status: NotificationStatus.loading,
          currentPage: 1,
          hasMoreData: true,
        ));
      } else if (!state.hasMoreData || state.status == NotificationStatus.loading) {
        return;
      } else {
        emit(state.copyWith(status: NotificationStatus.loading));
      }

      final token = await _tokenStorage.getAccessToken();
      final clientId = await _tokenStorage.getClientId();
      
      if (token == null || clientId == null) {
        emit(state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: 'Unauthorized',
        ));
        return;
      }

      final response = await _notiRepository.getNotis(
        clientId, 
        token,
        page: refresh ? 1 : state.currentPage,
      );

      final newNotifications = response.metadata;
      final hasMore = newNotifications.isNotEmpty;

      if (refresh) {
        emit(state.copyWith(
          notifications: newNotifications,
          status: NotificationStatus.success,
          currentPage: 2,
          hasMoreData: hasMore,
        ));
      } else {
        emit(state.copyWith(
          notifications: [...state.notifications, ...newNotifications],
          status: NotificationStatus.success,
          currentPage: state.currentPage + 1,
          hasMoreData: hasMore,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMoreData || state.status == NotificationStatus.loading) {
      return;
    }
    await fetchNotifications();
  }

  Future<void> refresh() async {
    await fetchNotifications(refresh: true);
  }
} 