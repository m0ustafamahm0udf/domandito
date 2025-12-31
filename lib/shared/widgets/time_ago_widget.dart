import 'dart:async';
import 'package:flutter/material.dart';
import 'package:domandito/core/utils/utils.dart'; // Assuming this is where timeAgo is

class TimeAgoWidget extends StatefulWidget {
  final DateTime date;
  final TextStyle? style;

  const TimeAgoWidget({super.key, required this.date, this.style});

  @override
  State<TimeAgoWidget> createState() => _TimeAgoWidgetState();
}

class _TimeAgoWidgetState extends State<TimeAgoWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every minute (60 seconds)
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(timeAgo(widget.date, context), style: widget.style);
  }
}
