import 'package:domandito/core/constants/app_constants.dart';
import 'package:domandito/core/utils/extentions.dart';
import 'package:flutter/material.dart';

class AnonymousSwitchSection extends StatelessWidget {
  final bool isAnonymous;
  final bool canAskedAnonymously;
  final String recipientName;
  final bool isRandomLoading;
  final Function(bool) onChanged;

  const AnonymousSwitchSection({
    super.key,
    required this.isAnonymous,
    required this.canAskedAnonymously,
    required this.recipientName,
    required this.isRandomLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      value: isAnonymous,
      onChanged: (value) {
        if (isRandomLoading) return;
        if (!canAskedAnonymously) {
          AppConstance().showInfoToast(
            context,
            msg: !context.isCurrentLanguageAr()
                ? '"$recipientName" prevens asking anonymously'
                : '"$recipientName" لا يسمح بهذه الخاصية',
          );
          return;
        }
        onChanged(value);
      },
      title: Text(
        !context.isCurrentLanguageAr() ? 'Anonymous' : 'مجهول',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
