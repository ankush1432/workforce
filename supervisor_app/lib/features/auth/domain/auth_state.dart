import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({required this.isAuthenticated, this.supervisor});

  final bool isAuthenticated;
  final Map<String, dynamic>? supervisor;

  @override
  List<Object?> get props => [isAuthenticated, supervisor];
}
