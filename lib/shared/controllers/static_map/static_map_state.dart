part of 'static_map_cubit.dart';

sealed class StaticMapState extends Equatable {
  const StaticMapState();

  @override
  List<Object> get props => [];
}

final class StaticMapInitial extends StaticMapState {}

final class StaticMapLoading extends StaticMapState {}

final class StaticMapFailed extends StaticMapState {}

final class StaticMapSuccess extends StaticMapState {}
