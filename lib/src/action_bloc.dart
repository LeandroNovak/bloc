import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// {@template token_action_bloc}
/// A class that manages the state of the application and provides a stream of
/// state changes. It also provides a stream of actions that can be used to
/// dispatch actions to the view.
///
/// It also provides a handler to process events of type [Event] dispatched from
/// view using the [addEvent] method.
/// {@endtemplate}
abstract class ActionBloc<State, Event, Action> extends Bloc<State, Event> {
  ///{@macro token_action_bloc}
  ActionBloc(super.initialState) {
    _actionsSubject = PublishSubject<Action>();
  }

  late final PublishSubject<Action> _actionsSubject;

  @override
  bool get isClosed => super.isClosed || _actionsSubject.isClosed;

  /// A stream of actions.
  Stream<Action> get actionStream => _actionsSubject.stream;

  final Map<ActionCallback<Action>, StreamSubscription<Action>>
      _actionsSubscriptions = {};

  /// Emits the given [action].
  @protected
  void emitAction(Action action) {
    _actionsSubject.add(action);
  }

  /// Listens to the actions changes.
  ///
  /// [callback] is called whenever an [Action] is emitted.
  ///
  /// [modifier] is used to modify the stream of actions before it is listened.
  ///
  /// Example of common usage of [modifier]:
  ///
  /// 1. You want to apply a debounce/throttle time to the stream of actions:
  ///
  /// ```dart
  /// listenAction(
  ///   (action) => print(action),
  ///   modifier: ListenerModifiers.debounceTime(Duration(milliseconds: 500)),
  /// );
  /// ```
  ///
  /// 2. You want to apply a flat/switch/exaust map to the stream of actions:
  ///
  /// ```dart
  /// listenAction(
  ///   (action){
  ///     await _someAsyncFunction();
  ///     print(action);
  ///   },
  ///   modifier: ListenerModifiers.switchMap(),
  /// );
  /// ```
  void listenAction(
    ActionCallback<Action> callback, {
    ListenerModifier<Action>? modifier,
  }) {
    final listenerModifier = modifier ?? ListenerModifiers.defaultModifier();

    final subscription = listenerModifier(
      actionStream,
      ListenerMappers.defaultMapper(callback),
    ).listen(null);

    subscriptions.add(subscription);
    _actionsSubscriptions[callback] = subscription;
  }

  /// Removes the [listener] from the action stream.
  ///
  /// If the [listener] is not present in the action stream, then does nothing.
  void removeActionListener(ActionCallback<Action> listener) {
    final subscription = _actionsSubscriptions.remove(listener);
    if (subscription != null) {
      subscription.cancel();
    }
  }

  /// Closes the action stream.
  /// It also cancels all the subscriptions.
  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _actionsSubject.close();
    _actionsSubscriptions.forEach(
      (key, value) {
        value.cancel();
      },
    );
  }
}
