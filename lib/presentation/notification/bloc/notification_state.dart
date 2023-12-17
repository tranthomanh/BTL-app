import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
}

class NotificationStateInitial extends NotificationState {
  @override
  List<Object> get props => [];
}
