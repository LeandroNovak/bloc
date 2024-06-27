import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// {@template action_bloc_builder}
/// A widget that subscribes to the changes of state and actions of the given
/// [bloc] and rebuilds itself when the state changes.
/// When an action is dispatched, the [onAction] callback is called.
///
/// [builder] is called every time the state changes, and it is passed the
/// current [State] and the [child] widget.
///
/// [child] is optional and can be used to optimize the number of times the
/// [builder] is called.
///
/// [builder] is not called when the state is null.
/// {@endtemplate}
class ActionBlocBuilder<State, Action> extends StatelessWidget {
  /// {@macro action_bloc_builder}
  const ActionBlocBuilder({
    required this.builder,
    required this.bloc,
    required this.onAction,
    this.listenWhen,
    this.buildWhen,
    this.child,
    super.key,
  });

  /// Called every time the state changes.
  final StateBuilder<State> builder;

  /// Called every time an action is dispatched.
  final ActionCallback<Action> onAction;

  /// The [ActionBloc] that this widget subscribes to.
  final ActionBloc<State, dynamic, Action> bloc;

  /// A function that verifies if the should or not to call the [onAction]
  /// based on the previous and current [Action].
  final ActionListenerCondition<Action>? listenWhen;

  /// A function that verifies if the should or not to rebuild the widget
  /// based on the previous and current [State].
  final StateBuildCondition<State>? buildWhen;

  /// The child widget that is passed to the [builder].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ActionBlocListener(
      bloc: bloc,
      onAction: onAction,
      listenWhen: listenWhen,
      child: BlocBuilder(
        bloc: bloc,
        buildWhen: buildWhen,
        builder: builder,
        child: child,
      ),
    );
  }
}
