import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Base UseCase with params
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base UseCase without params
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base Stream UseCase
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// No Params class for UseCases that don't need params
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
