import 'package:domandito/core/utils/extentions.dart';
import 'package:domandito/shared/style/app_colors.dart';
import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';


// class ImageViewScreen extends StatefulWidget {
//   final List images;
//   final String title;
//   final int initialIndex;
//   final Function(int index) onBack;

//   const ImageViewScreen({
//     super.key,
//     required this.images,
//     required this.title,
//     this.initialIndex = 0,
//     required this.onBack,
//   });

//   @override
//   State<ImageViewScreen> createState() => _ImageViewScreenState();
// }

// class _ImageViewScreenState extends State<ImageViewScreen> {
//   late PageController _pageController;
//   late int _currentIndex;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: AppColors.primary,
//           ),
//         ),
//         leading: IconButton.filled(onPressed: () => context.back(), icon: const Icon(Icons.arrow_back)),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Hero(

//               tag: widget.images[_currentIndex],
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: widget.images.length,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                   widget.onBack(index);
//                 },
//                 itemBuilder: (context, index) {
//                   return InteractiveViewer(
//                     panEnabled: true,
//                     maxScale: 4,
//                     child: Center(
//                       child: CustomNetworkImage(
//                         url: widget.images[index],
//                         radius: 0,
//                         height: null,
//                         width: null,
//                         boxFit: BoxFit.contain,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           if (widget.images.length > 1)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Text(
//                 '${_currentIndex + 1}/${widget.images.length}',
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }


class ImageViewScreen extends StatefulWidget {
  final List images;
  final int initialIndex;
  final Function(int index) onBack;

  const ImageViewScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
    required this.onBack,
  });

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showUI = !_showUI;
              });
            },
            onVerticalDragEnd: (_) {
              context.back();
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                widget.onBack(index);
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CustomNetworkImage(
                      url: widget.images[index],
                      radius: 0,
                      boxFit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          /// زر الإغلاق
          if (_showUI)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primary, size: 28),
                onPressed: () => context.back(),
              ),
            ),

          /// عداد الصور
          if (_showUI && widget.images.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
