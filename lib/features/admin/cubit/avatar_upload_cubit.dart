import 'dart:io';

import 'package:exam_guardian/features/admin/cubit/user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'avatar_upload_state.dart';

class AvatarCubit extends Cubit<AvatarState> {
  final UserCubit userCubit;

  AvatarCubit({required this.userCubit}) : super(AvatarState());

  Future<void> pickImage(String role, String id) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      emit(state.copyWith(selectedImage: imageFile));
      userCubit.setSelectedAvatar(role, id, imageFile);
    }
  }

  void clearSelectedImage(String role, String id) {
    emit(state.copyWith(selectedImage: null));
    userCubit.clearSelectedAvatar(role, id);
  }
}