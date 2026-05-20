import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state_view.dart';
import 'error_state_view.dart';
import 'list_screen_skeleton.dart';

class AsyncValueBody<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final bool Function(T data)? isEmpty;
  final Widget Function()? empty;
  final VoidCallback? onRetry;

  const AsyncValueBody({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.isEmpty,
    this.empty,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const ListScreenSkeleton(),
      error: (err, stack) {
        if (error != null) return error!(err, stack);
        return ErrorStateView(
          message: 'Não foi possível carregar os dados.',
          retryLabel: onRetry != null ? 'Tentar novamente' : null,
          onRetry: onRetry,
        );
      },
      data: (resolved) {
        if (isEmpty != null && empty != null && isEmpty!(resolved)) {
          return empty!();
        }
        return _FadeInContent(child: data(resolved));
      },
    );
  }
}

class _FadeInContent extends StatelessWidget {
  final Widget child;

  const _FadeInContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: child,
    );
  }
}

/// Convenience builder for list screens with a standard empty state.
class AsyncListBody<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data) isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final VoidCallback? onRetry;

  const AsyncListBody({
    super.key,
    required this.value,
    required this.data,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncValueBody<T>(
      value: value,
      isEmpty: isEmpty,
      onRetry: onRetry,
      empty: () => EmptyStateView(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      ),
      data: data,
    );
  }
}
