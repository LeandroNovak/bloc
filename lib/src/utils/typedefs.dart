// ignore_for_file: comment_references

import 'dart:async';

import 'package:flutter/widgets.dart';

/// A function that builds a widget given the current [State] and the [child].
typedef StateBuilder<State> = Widget Function(
  BuildContext context,
  State state,
  Widget? child,
);

/// A function that is called when the [State] changes.
typedef StateCallback<State> = FutureOr<void> Function(
  State state,
);

/// A function that is called when an [Action] is dispatched.
typedef ActionCallback<Action> = FutureOr<void> Function(
  Action action,
);

/// A function that verifies if the should or not to call the [ReStateBuilder]
/// based on the previous and current [State].
typedef StateBuildCondition<State> = bool Function(
  State previousState,
  State currentState,
);

/// A function that verifies if the should or not to call the [ReActionCallback]
/// based on the previous and current [Action].
typedef ActionListenerCondition<Action> = bool Function(
  Action? previousAction,
  Action currentAction,
);

/// A function that modifies the listener to be called when the [T] changes.
///
/// Can be used to apply operators like `switchMap`, `flatMap`, `debounce`, etc.
///
/// See [ListenerModifiers] for more information.
typedef ListenerModifier<T> = Stream<T> Function(
  Stream<T> listener,
  ListenerMapper<T> mapper,
);

/// A function that maps the [event] from listener stream
typedef ListenerMapper<T> = Stream<T> Function(dynamic event);

/// A function that is called when an [Event] is dispatched.
typedef EventCallback<Event> = FutureOr<void> Function(
  Event event,
);
