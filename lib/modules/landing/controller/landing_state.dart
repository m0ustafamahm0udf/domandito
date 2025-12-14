part of 'landing_cubit.dart';

abstract class LandingState extends Equatable {
  const LandingState();

  @override
  List<Object> get props => [];
}

class LandingInitial extends LandingState {}

class ChangeBottomNavBarState extends LandingState {
  final int index;

  const ChangeBottomNavBarState({required this.index});
}
