import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyView({
    super.key,
    this.icon = Icons.search_off,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}