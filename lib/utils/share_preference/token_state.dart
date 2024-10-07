import 'package:equatable/equatable.dart';

class TokenState extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final String? clientId;
  final bool loading;
  final bool isExpired;

  const TokenState({
    this.accessToken,
    this.refreshToken,
    this.clientId,
    this.loading = false,
    this.isExpired = false
  });

  TokenState copyWith({
    String? accessToken,
    String? refreshToken,
    String? clientId,
    bool? loading,
    bool? isExpired
  }) {
    return TokenState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      clientId: clientId ?? this.clientId,
      loading: loading ?? this.loading,
      isExpired: isExpired ?? this.isExpired
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, clientId, loading, isExpired];
}
