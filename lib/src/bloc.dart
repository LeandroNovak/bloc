import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// {@template token_bloc}
/// A class that manages the state of the application and provides a stream of
/// state changes.
///
/// It also provides a handler for events of type [Event] dispatched from the
/// view using the [addEvent] method.
/// {@endtemplate}
abstract class Bloc<State, Event> extends SubscriptionHolder {
  ///{@macro token_bloc}
  Bloc(State initialState) {
    _statesSubject = BehaviorSubject<State>.seeded(initialState);
    _eventsSubject = PublishSubject<Event>();
  }

  late final BehaviorSubject<State> _statesSubject;
  late final PublishSubject<Event> _eventsSubject;
  final Map<Type, Function> _eventsMap = {};

  /// Whether the TokenBloc is closed for adding new events.
  ///
  /// The TokenBloc becomes closed by calling [dispose] method.
  @mustCallSuper
  bool get isClosed => _eventsSubject.isClosed || _statesSubject.isClosed;

  /// The current state.
  State get state => _statesSubject.value;

  /// A stream of state.
  Stream<State> get stateStream => _statesSubject.stream;

  final Map<StateCallback<State>, StreamSubscription<State>>
      _stateSubscriptions = {};

  /// Emits the given [state].
  @protected
  void emitState(State state) {
    _statesSubject.add(state);
  }

  /// Emits all the states dispatched by the given [streamOfStates].
  ///
  /// Useful when the bloc needs to emit states dispatched from a handler method
  /// that returns a stream of states
  ///
  /// Example:
  ///
  /// ```dart
  /// on<FetchCartListLenghtEvent>(
  ///   (event) => emitStateStream(_fetchMyCartListLength(event)),
  /// );
  ///
  /// Stream<StoreState> _fetchMyCartListLength(
  ///   FetchCartListLenghtEvent event,
  /// ) async* {
  ///   yield Loading();
  ///   //...
  ///   yield Idle();
  /// }
  /// ```
  @protected
  Future<void> emitStatesFromStream(Stream<State> streamOfStates) {
    final streamCompleter = Completer<void>();

    final subscription = streamOfStates.listen(
      emitState,
      onDone: streamCompleter.complete,
      onError: streamCompleter.completeError,
    );

    subscriptions.add(subscription);
    return streamCompleter.future.whenComplete(
      () => subscriptions.remove(subscription),
    );
  }

  /// Listen to the given [stream] events with [onData] callback, adding it
  /// subscription to [subscriptions].
  ///
  /// Useful when the bloc needs to listen to an external Stream.
  ///
  /// Example:
  ///
  /// ```dart
  /// class StoreBloc extends Bloc<StoreState, StoreEvent>{
  ///   StoreBloc({required Stream<bool> cartChangeStream})
  ///         : super(const Loading()){
  ///     on<FetchCartQuantityEvent>(_fetchCartQuantity);
  ///
  ///     listenTo(
  ///       cartChangeStream,
  ///       onData: (data) => addEvent(FetchCartQuantityEvent()),
  ///     );
  ///   }
  /// }
  /// ```
  @protected
  void listenTo<T>(Stream<T> stream, {required ValueChanged<T> onData}) {
    stream.listen(onData).addTo(subscriptions);
  }

  /// Guards a callback so it only runs if the current state is of the required
  /// type.
  ///
  ///
  @protected
  Future<void> ifState<RequiredState extends State>(
    Future<void> Function(RequiredState state) callback,
  ) async {
    final lastState = state;
    if (lastState is RequiredState) {
      await callback(lastState);
    }
  }

  /// Guards a callback so it only runs if the current state is of the required
  /// type.
  ///
  ///
  @protected
  void ifStateSync<RequiredState extends State>(
    void Function(RequiredState state) callback,
  ) {
    final lastState = state;
    if (lastState is RequiredState) {
      callback(lastState);
    }
  }

  /// Handles the callback that returns a [State] or a [Future] of [State] in
  /// a safe way and emits the returned state.
  ///
  /// If the [callback] returns a [State], then returned value is emitted as the
  /// new state. It also pass the last state to the callback as an argument.
  ///
  /// If the [callback] throws an error, then [onError] is called with the last
  /// state and the error. The state returned by [onError] is emitted as the new
  /// state.
  ///
  /// If [onError] is not provided, then the error is ignored.
  ///
  /// If [initialState] is provided, then the state is set to the [initialState]
  /// before calling the callback. Usefull when the callback is an async
  /// function and you want to show a loading state.
  @protected
  Future<void> guardState(
    FutureOr<State> Function(State lastState) callback, {
    FutureOr<State> Function(Object? error)? onError,
    State? initialState,
  }) async {
    final lastState = state;

    if (initialState != null) {
      emitState(initialState);
    }

    try {
      emitState(await callback(lastState));
    } catch (error) {
      if (onError != null) {
        emitState(await onError(error));
      }
    }
  }

  /// Listens to the state changes.
  ///
  /// [callback] is called whenever a [State] is emitted.
  ///
  /// [modifier] is used to modify the stream of state before it is listened to.
  ///
  /// Example of common usage of [modifier]:
  ///
  /// 1. You want to apply a debounce/throttle time to the stream of states:
  ///
  /// ```dart
  /// listenState(
  ///   (state) => print(state),
  ///   modifier: ListenerModifiers.debounceTime(Duration(milliseconds: 500)),
  /// );
  /// ```
  ///
  /// 2. You want to apply a flat/switch/exaust map to the stream of states:
  ///
  /// ```dart
  /// listenState(
  ///   (state) {
  ///     await _someAsyncFunction();
  ///     print(state);
  ///   },
  ///   modifier: ListenerModifiers.switchMap(),
  /// );
  /// ```
  void listenState(
    StateCallback<State> callback, {
    ListenerModifier<State>? modifier,
  }) {
    final listenerModifier = modifier ?? ListenerModifiers.defaultModifier();

    final subscription = listenerModifier(
      stateStream,
      ListenerMappers.defaultMapper(callback),
    ).listen(null);

    subscriptions.add(subscription);
    _stateSubscriptions[callback] = subscription;
  }

  /// Removes the [listener] from the state stream.
  ///
  /// If the [listener] is not present in the state stream, then does nothing.
  void removeStateListener(StateCallback<State> listener) {
    final subscription = _stateSubscriptions.remove(listener);
    if (subscription != null) {
      subscription.cancel();
    }
  }

  /// Listens to the events of subtype [T] that are dispatched.
  ///
  /// Throws an exception if an event of type [T] already has a listener.
  ///
  /// [callback] is called whenever an event of type [T] is dispatched.
  ///
  /// [modifier] is used to modify the stream of events before it is listened.
  ///
  /// Example of common usage of [modifier]:
  ///
  /// 1. You want to apply a debounce/throttle time to the stream of events:
  ///
  /// ```dart
  /// on<FetchCartListLenghtEvent>(
  ///   (event) => _fetchMyCartListLength(),
  ///   modifier: ListenerModifiers.debounceTime(Duration(milliseconds: 500)),
  /// );
  /// ```
  ///
  /// 2. You want to apply a flat/switch/exaust map to the stream of events:
  ///
  /// ```dart
  /// on<FetchCartListLenghtEvent>(
  ///   (event) => _fetchMyCartListLength(),
  ///   modifier: ListenerModifiers.switchMap(),
  /// );
  /// ```
  @protected
  void on<T extends Event>(
    EventCallback<T> callback, {
    ListenerModifier<T>? modifier,
  }) {
    final type = T;
    if (_eventsMap.containsKey(type)) {
      throw StateError(
        'on() called more than once for event of type $type. '
        'Make sure to call on<$type>() only once.',
      );
    }
    _eventsMap[type] = callback;

    final stream = _eventsSubject.stream.whereType<T>();

    final listenerModifier = modifier ?? ListenerModifiers.defaultModifier();

    final subscription = listenerModifier(
      stream,
      ListenerMappers.defaultMapper(callback),
    ).listen(null);

    subscriptions.add(subscription);
  }

  /// Dispatches the given [event].
  ///
  /// Throws an exception if no handler is found for the event.
  void addEvent(Event event) {
    final type = event.runtimeType;

    if (!_eventsMap.containsKey(type)) {
      throw StateError(
        'No handler found for event of type $type. '
        'Make sure to call on<$type>() before process the event.',
      );
    }

    _eventsSubject.add(event);
  }

  /// Disposes the TokenBloc.
  /// It also cancels all the subscriptions.
  @mustCallSuper
  void dispose() {
    subscriptions.dispose();
    _eventsSubject.close();
    _statesSubject.close();
    _eventsMap.clear();
    _stateSubscriptions.forEach(
      (key, value) {
        value.cancel();
      },
    );
  }
}
