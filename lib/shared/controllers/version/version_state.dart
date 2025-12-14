import 'package:domandito/shared/models/version_model.dart';
import 'package:equatable/equatable.dart';

sealed class VersionState extends Equatable {
  const VersionState();

  @override
  List<Object> get props => [];
}

final class VersionInitial extends VersionState {}

final class VersionLoading extends VersionState {}

final class VersionUpdateAvalibleState extends VersionState {
  final VersionModel version;

  const VersionUpdateAvalibleState({required this.version});
}
