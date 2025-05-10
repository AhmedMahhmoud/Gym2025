import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.statusCode,
  });
  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

class BadRequestFailure extends Failure {
  const BadRequestFailure({required super.message, super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message}) : super(statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message}) : super(statusCode: 404);
}
