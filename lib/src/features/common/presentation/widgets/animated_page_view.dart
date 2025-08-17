import 'package:flutter/material.dart';

class AnimatedPageView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Axis scrollDirection;

  const AnimatedPageView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<AnimatedPageView> createState() => _AnimatedPageViewState();
}

class _AnimatedPageViewState extends State<AnimatedPageView> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: widget.scrollDirection,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        // Calculate animation values based on current page position
        final difference = (index - _currentPage).abs();
        final isCurrentPage = difference < 1;
        
        // Scale and translate effects for smooth transitions
        final scale = isCurrentPage ? 1.0 - (difference * 0.1) : 0.9;
        final translateY = isCurrentPage ? difference * 50 : 50.0;
        final opacity = isCurrentPage ? 1.0 - (difference * 0.3) : 0.7;

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            return Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: Offset(0.0, translateY),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: difference * 20,
                      bottom: difference * 10,
                    ),
                    child: widget.itemBuilder(context, index),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}