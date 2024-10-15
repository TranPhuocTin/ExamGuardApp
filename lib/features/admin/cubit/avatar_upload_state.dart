import 'dart:io';

class AvatarState {
  final File? selectedImage;
  final bool isLoading;
  final String? error;

  AvatarState({
    this.selectedImage,
    this.isLoading = false,
    this.error,
  });

  AvatarState copyWith({
    File? selectedImage,
    bool? isLoading,
    String? error,
  }) {
    return AvatarState(
      selectedImage: selectedImage ?? this.selectedImage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}