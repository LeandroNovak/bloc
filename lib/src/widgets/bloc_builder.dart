import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

/// {@template bloc_builder}
/// A widget that subscribes to the state changes of the given [bloc] and
/// rebuilds itself when the state changes.
///
/// [builder] is called every time the state changes, and it is passed the
/// current [S] and the [child] widget.
///
/// [child] is optional and can be used to optimize the number of times the
/// [builder] is called.
///
/// [builder] is not called when the state is null.
/// {@endtemplate}
class BlocBuilder<S> extends StatefulWidget {
  /// {@macro bloc_builder}
  const BlocBuilder({
    required this.bloc,
    required this.builder,
    this.buildWhen,
    this.child,
    super.key,
  });

  /// Called every time the state changes.
  final StateBuilder<S> builder;

  /// The [Bloc] that this widget subscribes to.
  final Bloc<S, dynamic> bloc;

  /// A function that verifies if the should or not to call the [builder]
  /// based on the previous and current [S].
  final StateBuildCondition<S>? buildWhen;

  /// The child widget that is passed to the [builder].
  final Widget? child;

  @override
  State<BlocBuilder<S>> createState() => _BlocBuilderState<S>();
}

class _BlocBuilderState<S> extends State<BlocBuilder<S>> {
  late S _currentState;
  late bool _isFirstBuild;

  @override
  void initState() {
    super.initState();
    _isFirstBuild = true;
    _currentState = widget.bloc.state;
    widget.bloc.listenState(_listenToStateChange);
  }

  @override
  void dispose() {
    widget.bloc.removeStateListener(_listenToStateChange);
    super.dispose();
  }

  void _listenToStateChange(S newState) {
    if (_isFirstBuild) {
      _isFirstBuild = false;
      return;
    }

    if (widget.buildWhen?.call(_currentState, newState) ?? true) {
      setState(() {
        _currentState = newState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentState, widget.child);
  }
}
