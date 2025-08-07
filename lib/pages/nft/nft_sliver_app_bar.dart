import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NftSliverAppBarWithImage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final bool isLoading;
  final double expandedHeight;
  final double scrollProgress;
  final bool showTitle;
  final Color? backgroundColor;

  const NftSliverAppBarWithImage({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.isLoading,
    required this.expandedHeight,
    required this.scrollProgress,
    required this.showTitle,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<NftSliverAppBarWithImage> createState() =>
      _NftSliverAppBarWithImageState();
}

class _NftSliverAppBarWithImageState extends State<NftSliverAppBarWithImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late Animation<double> _imageScaleAnimation;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _imageScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _imageAnimationController, curve: Curves.easeOutBack),
    );
    // 启动动画
    Future.delayed(Duration.zero, () {
      if (mounted) _imageAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: widget.expandedHeight,
      pinned: true,
      title: AnimatedOpacity(
        opacity: widget.showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.title,
          style: TextStyle(
            color: Color.lerp(
              Colors.transparent,
              Colors.black,
              widget.scrollProgress,
            ),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: widget.backgroundColor ?? const Color(0xFFB2CBF6),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: const SizedBox.shrink(),
        collapseMode: CollapseMode.parallax,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 渐变背景
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB2CBF6),
                    const Color(0xFFFFFFFF),
                  ],
                ),
              ),
            ),
            // 居中的主图 - 添加缩放动画
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                child: widget.isLoading
                    ? null
                    : ScaleTransition(
                        scale: _imageScaleAnimation,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: Stack(
                                  children: [
                                    InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: Image.network(
                                        widget.imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Color(0xFFFFFFFF)),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Image.network(
                              height: 280,
                              widget.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.transparent,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
