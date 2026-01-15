import 'package:flutter/material.dart';

class ErrorRefreshMessage extends StatelessWidget {
  const ErrorRefreshMessage({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              'Oops, it looks like there was an error.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              "Pull down to refresh. If it doesn't work, close the app and open it again!",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}