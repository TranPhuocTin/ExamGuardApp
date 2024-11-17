import 'package:equatable/equatable.dart';

class TokenState extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final String? clientId;
  final String? cliendRole;
  final bool loading;
  final bool isExpired;
  final Object? error;

  bool get hasError => error != null;

  const TokenState({
    this.accessToken,
    this.refreshToken,
    this.clientId,
    this.cliendRole,
    this.loading = false,
    this.isExpired = false,
    this.error,
  });

  TokenState copyWith({
    String? accessToken,
    String? refreshToken,
    String? clientId,
    String? clientRole,
    bool? loading,
    bool? isExpired,
    Object? error,
  }) {
    return TokenState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      clientId: clientId ?? this.clientId,
      cliendRole: clientRole ?? this.cliendRole,
      loading: loading ?? this.loading,
      isExpired: isExpired ?? this.isExpired,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, clientId, loading, isExpired, error];
}
