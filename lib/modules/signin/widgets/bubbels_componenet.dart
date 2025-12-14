import 'package:domandito/shared/widgets/custom_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubblesComponent extends StatefulWidget {
  const BubblesComponent({super.key, required this.onShow,  this.isHome = false});
  final Function(bool isShow) onShow;
  final bool isHome;

  @override
  State<BubblesComponent> createState() => _BubblesComponentState();
}

class _BubblesComponentState extends State<BubblesComponent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> images = [];

  Future<void> getImages() async {
    await FirebaseFirestore.instance
        .collection('intro')
        .doc('images')
        .get()
        .then((value) {
          images = List<String>.from(value.data()!['images']);
          setState(() {
            widget.onShow(true);
          });
        });
  }
  

  @override
  Widget build(BuildContext context) {
    // print('BubblesComponent');
    if (images.isEmpty) {
      return SizedBox(
        );
    }
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.01, 0.5, 0.4, 1.1],
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: SizedBox(
        height: Get.height,
        width: Get.width,
        child: GridView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 56,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CustomNetworkImage(
                  url: images[index % images.length],
                  radius: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    getImages();
    super.initState();
  if (!widget.isHome) {
      Future.delayed(const Duration(seconds: 1), () {
      try {
        _startScrollingLoop();
        setState(() {});
      } catch (e) {}
    });
  }
  }

  void _startScrollingLoop() {
    int duration = 30;
    // TODO increase duration in long list
    _scrollController
        .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: duration), // Adjust scroll duration
          curve: Curves.linear,
        )
        .then((_) {
          _scrollController
              .animateTo(
                0.0,
                duration: Duration(seconds: duration),
                curve: Curves.linear,
              )
              .then((_) {
                // Continue the loop
                _startScrollingLoop();
              });
        });
  }
}
