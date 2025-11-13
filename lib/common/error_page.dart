import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  const ErrorText({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  const ErrorPage({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorText(error: error, onRetry: onRetry),
    );
  }
}
