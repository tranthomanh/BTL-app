import 'package:equatable/equatable.dart';

abstract class BlockListState extends Equatable {
  const BlockListState();
}

class BlockListStateStateIntial extends BlockListState {


  @override
  List<Object?> get props => [];
}

class MainMessageStateError extends BlockListState {
  final String error;

  const MainMessageStateError(this.error);

  @override
  List<Object?> get props => [error];
}