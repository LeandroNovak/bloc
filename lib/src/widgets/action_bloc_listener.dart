import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// {@template action_bloc_listener}
/// A widget that subscribes to the action changes of the given [bloc] and
/// calls the [onAction] callback when an action is dispatched.
/// The [child] widget is not rebuilt when an action is dispatched.
/// {@endtemplate}
class ActionBlocListener<Action> extends StatefulWidget {
  /// {@macro action_bloc_listener}
  const ActionBlocListener({
    required this.bloc,
    required this.onAction,
    required this.child,
    this.listenWhen,
    super.key,
  });

  /// Called every time an action is dispatched.
  final ActionCallback<Action> onAction;

  /// The [ActionBloc] that this widget subscribes to.
  final ActionBloc<dynamic, dynamic, Action> bloc;

  /// A function that verifies if the should or not to call the [onAction]
  /// based on the previous and current [Action].
  final ActionListenerCondition<Action>? listenWhen;

  /// The child widget that is not rebuilt when an action is dispatched.
  final Widget child;

  @override
  State<ActionBlocListener<Action>> createState() =>
      _ActionBlocListenerState<Action>();
}

class _ActionBlocListenerState<Action>
    extends State<ActionBlocListener<Action>> {
  ActionBloc<dynamic, dynamic, Action> get actionBloc => widget.bloc;
  Action? _previousAction;

  @override
  void initState() {
    super.initState();
    actionBloc.listenAction(_listenToActionChange);
  }

  @override
  void dispose() {
    actionBloc.removeActionListener(_listenToActionChange);
    super.dispose();
  }

  void _listenToActionChange(Action action) {
    if (widget.listenWhen?.call(_previousAction, action) ?? true) {
      widget.onAction(action);
    }
    _previousAction = action;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
