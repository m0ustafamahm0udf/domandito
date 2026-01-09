import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

class CompressionProgressSection extends StatelessWidget {
  final bool isCompressing;
  final double compressionProgress;
  final VoidCallback onCancel;

  const CompressionProgressSection({
    super.key,
    required this.isCompressing,
    required this.compressionProgress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCompressing) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: compressionProgress / 100,
                backgroundColor: Colors.grey[300],
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: onCancel,
              child: Text(
                !context.isCurrentLanguageAr() ? 'Cancel' : 'إلغاء',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          (!context.isCurrentLanguageAr()
              ? 'Compressing: ${compressionProgress.toStringAsFixed(0)}%'
              : 'جاري الضغط: ${compressionProgress.toStringAsFixed(0)}%'),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
