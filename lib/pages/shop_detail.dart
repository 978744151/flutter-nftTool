import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // 添加这行

import '../config/comment_api.dart';
import 'package:intl/intl.dart'; // 添加这行
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/http_client.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/storage.dart'; // 添加导入
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/src/widgets/heroes.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import '../api/nft.dart';

class NftInfo {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String quantity;
  final Map<String, dynamic>? owner; // 直接使用 Map

  NftInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.owner,
  });
  factory NftInfo.fromJson(Map<String, dynamic> json) {
    return NftInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      owner: json['owner'] as Map<String, dynamic>?,
    );
  }
}

class ShopDetail extends StatefulWidget {
  final String id; // 添加 id 参数

  const ShopDetail({
    super.key,
    required this.id,
  });

  @override
  State<ShopDetail> createState() => _ShopDetailState();
}

class _ShopDetailState extends State<ShopDetail> with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  late NftInfo nftInfo;
  bool _showTitle = false; // 添加标题显示控制
  double _scrollProgress = 0.0; // 添加滚动进度变量
  late AnimationController _imageAnimationController;
  late Animation<double> _imageScaleAnimation;
  late AnimationController _detailsAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _tapAnimationController;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 初始化动画控制器
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 立即初始化动画
    _imageScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _imageAnimationController, curve: Curves.easeOutBack));

    _detailsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _detailsAnimationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _detailsAnimationController, curve: Curves.easeOut));

    _tapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );

    // 初始化 nftInfo
    nftInfo = NftInfo(
      id: '',
      name: '',
      imageUrl: '',
      price: '',
      quantity: '',
    );

    // 获取数据并启动动画
    fetchData();

    fetchConsignmentsList();

    // 延迟启动动画，确保有足够时间初始化
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _imageAnimationController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _detailsAnimationController.forward();
        });
      }
    });
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    try {
      final ids = widget.id;
      final response = await HttpClient.get('/nfts/$ids');

      if (!mounted) return;
      if (response['success'] != false) {
        final data = response['data'];
        // 确保数据格式正确
        if (data != null && data is Map<String, dynamic>) {
          setState(() {
            nftInfo = NftInfo.fromJson(data);
            isLoading = false;
          });
          // 验证状态更新
        } else {
          print('Invalid data format: $data');
        }
      }
    } catch (e) {
      print(e);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      // 添加错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新失败：${e.toString()}')),
      );
    }
    // 返回 Future 完成
    return Future.value();
  }

  Future<void> fetchConsignmentsList() async {
    if (!mounted) return;
    try {
      final ids = widget.id;
      final response = await HttpClient.get(NftConfigApi.getNFTConsignments);

      // if (!mounted) return;
      // if (response['success'] != false) {
      //   final data = response['data'];
      //   // 确保数据格式正确
      //   if (data != null && data is Map<String, dynamic>) {
      //     setState(() {});
      //     // 验证状态更新
      //   } else {
      //     print('Invalid data format: $data');
      //   }
      // }
    } catch (e) {
      print(e);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      // 添加错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新失败：${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imageAnimationController.dispose();
    _detailsAnimationController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final scrollProgress = notification.metrics.pixels / 200.0;
          setState(() {
            _scrollProgress = scrollProgress.clamp(0.0, 1.0);
            _showTitle = _scrollProgress > 0.5;
          });
        }
        return false;
      },
      child: Hero(
        tag: "nft-detail-${widget.id}",
        child: Material(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 340,
                    pinned: true,
                    title: AnimatedOpacity(
                      opacity: _showTitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        nftInfo.name,
                        style: TextStyle(
                          color: Color.lerp(
                            Colors.transparent,
                            Colors.black,
                            _scrollProgress,
                          ),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    backgroundColor: Color(0xFFB2CBF6),
                    // elevation: _scrollProgress * 2, //
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.zero,
                      // 不显示 FlexibleSpaceBar 的标题
                      title: const SizedBox.shrink(),
                      collapseMode: CollapseMode.parallax, // 视差折叠效果
                      stretchModes: [
                        StretchMode.zoomBackground, // 背景放大（拉伸时）
                        StretchMode.blurBackground, // 背景模糊（拉伸时）
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
                                  Colors.white, // 渐变结束色改为白色
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
                              child: isLoading
                                  ? null
                                  : ScaleTransition(
                                      scale: _imageScaleAnimation,
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Stack(
                                                children: [
                                                  InteractiveViewer(
                                                    minScale: 0.5,
                                                    maxScale: 4.0,
                                                    child: Image.network(
                                                      nftInfo.imageUrl,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    top: 10,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.white),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
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
                                            nftInfo.imageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
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
                          // 居中的主图
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nftInfo.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'once meta',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 添加小波浪动画
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '限量版',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '总量:  ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${nftInfo.quantity} 份',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '当前流通:  ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        '0份',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: const [
                          Tab(text: '寄售列表'),
                          Tab(text: '当前成交'),
                          Tab(text: 'NFT详情'),
                          Tab(text: '相关公告'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildConsignmentList(),
                  _buildCurrentDeals(),
                  _buildNFTDetails(),
                  _buildAnnouncements(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsignmentList() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 300),
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0.6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SizedBox(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    '幻殇·月光 #${index.toString().padLeft(4, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('0x${index}d8f...3e2a'),
                  trailing: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥0.01',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[600],
                          size: 16,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentDeals() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: const Center(
        child: Text(
          '当前成交',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildNFTDetails() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: const Center(
        child: Text(
          'NFT详情',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: const Center(
        child: Text(
          '相关公告',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
