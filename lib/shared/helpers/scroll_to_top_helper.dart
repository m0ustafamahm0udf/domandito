import 'package:domandito/shared/style/app_colors.dart';
import 'package:flutter/material.dart';

/// Helper class that provides scroll-to-top functionality
///
/// Usage:
/// 1. Create instance: `late ScrollToTopHelper _scrollHelper;`
/// 2. Initialize in initState: `_scrollHelper = ScrollToTopHelper(onScrollComplete: _onScrolledToTop);`
/// 3. Dispose in dispose: `_scrollHelper.dispose();`
/// 4. Add controller to your scrollable widget: `controller: _scrollHelper.scrollController`
/// 5. Add floating button in Scaffold: `floatingActionButton: _scrollHelper.buildButton()`
class ScrollToTopHelper {
  final VoidCallback? onScrollComplete;
  final double scrollThreshold;
  final Duration scrollDuration;
  final Curve scrollCurve;
  final Color buttonColor;
  final Color iconColor;

  late final ScrollController scrollController;
  final ValueNotifier<bool> showButton = ValueNotifier<bool>(false);

  ScrollToTopHelper({
    this.onScrollComplete,
    this.scrollThreshold = 400.0,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.scrollCurve = Curves.easeInOut,
    this.buttonColor = AppColors.primary,
    this.iconColor = Colors.white,
  }) {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollThreshold && !showButton.value) {
      showButton.value = true;
    } else if (scrollController.offset < scrollThreshold && showButton.value) {
      showButton.value = false;
    }
  }

  /// Scroll to top with animation
  void scrollToTop() {
    scrollController
        .animateTo(0, duration: scrollDuration, curve: scrollCurve)
        .then((_) {
          if (onScrollComplete != null) {
            onScrollComplete!();
          }
        });
  }

  /// Build the floating action button
  Widget buildButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: showButton,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();

        return FloatingActionButton.small(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: scrollToTop,
          backgroundColor: buttonColor,
          child: Icon(Icons.arrow_upward, color: iconColor),
        );
      },
    );
  }

  /// Dispose the scroll controller
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    showButton.dispose();
  }
}
