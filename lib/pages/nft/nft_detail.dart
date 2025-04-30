import 'package:flutter/material.dart';

import '../../utils/http_client.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import '../../api/nft.dart';

import '../../widgets/purchase_options_sheet.dart'; // Add this import

class NftInfo {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String quantity;
  final Map<String, dynamic>? owner; // 直接使用 Map
  final List<dynamic> editions;
  NftInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.editions,
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
      editions: json['editions'] ?? [],
    );
  }
}

class NftDetail extends StatefulWidget {
  final String id; // 添加 id 参数

  const NftDetail({
    super.key,
    required this.id,
  });

  @override
  State<NftDetail> createState() => _ShopDetailState();
}

class _ShopDetailState extends State<NftDetail> with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  late NftInfo nftInfo;
  List<Map<dynamic, dynamic>> allEditions = [];
  List<Map<dynamic, dynamic>> filteredEditions = [];
  int editionsCount = 0;
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
      editions: [],
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
          setState(() {
            editionsCount = filteredEditions.length;
            allEditions = List<Map<String, dynamic>>.from(nftInfo.editions);
            filteredEditions = allEditions.where((edition) {
              final status = edition['status'];
              return status == 2 || status == 3;
            }).toList();
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

  void _showPurchaseOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the sheet to take up more screen height
      shape: const RoundedRectangleBorder(
        // Add rounded corners to the top
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return PurchaseOptionsSheet(
            imageUrl: nftInfo.imageUrl,
            price: nftInfo.price,
            name: nftInfo.name,
            id: nftInfo.id // Assuming quantity represents stock
            // Pass other necessary data if needed
            );
      },
    );
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
            backgroundColor: const Color(0xFFFFFFFF),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 340,
                    pinned: true,
                    title: AnimatedOpacity(
                      opacity: _showTitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
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
                                  const Color(0xFFFFFFFF), // 渐变结束色改为白色
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
                                                          color: const Color(
                                                              0xFFFFFFFF)),
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
                        color: const Color(0xFFFFFFFF),
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
                                Container(
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
                              child: Text(
                                '¥ ${nftInfo.price}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 详情模块

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
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              // decoration: BoxDecoration(
                              //   color: Colors.blue[50],
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    nftInfo.owner != null &&
                                            nftInfo.owner!['nickname'] != null
                                        ? '拥有者：' +
                                            nftInfo.owner!['nickname']
                                                .toString()
                                        : '拥有者：ONCE',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NFT ID：' + nftInfo.id,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                  ),

                                  // 可根据实际需求添加更多属性
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Stack(
                children: [
                  Container(),
                  // 底部立即购买按钮
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Container(
                      color: Colors.white.withOpacity(0.95),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fixedSize: const Size.fromHeight(52),
                        ),
                        onPressed: () {
                          // TODO: 跳转购买流程或弹窗
                          _showNftDetailDialog(
                              context, nftInfo); // Pass the context
                        },
                        child: const Text(
                          '立即购买',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Remove the old top-level function if it exists
// void _showNftDetailDialog(BuildContext context) { ... }

void _showNftDetailDialog(BuildContext context, NftInfo nftInfo) {
  // Accept BuildContext
  // var context; // Remove this line
  print(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true, // 使用根导航器，确保覆盖所有UI元素
    backgroundColor: const Color(0xFFFFFFFF),
    elevation: 20,
    clipBehavior: Clip.antiAliasWithSaveLayer, // 添加裁剪行为
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isDismissible: true,
    enableDrag: true,
    builder: (BuildContext context) {
      // 获取editions数据并筛选status为2或3的项目
      return SizedBox(
        // heightFactor: 0.4,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 添加一个小横条作为拖动指示器
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Container(
                child: PurchaseOptionsSheet(
                    imageUrl: nftInfo.imageUrl, // 替换成实际的图片 URL
                    price: nftInfo.price, // 替换成实际的价格
                    name:
                        nftInfo.name, // 替换成实际的库存uming quantity represents stock
                    id: nftInfo.id
                    // Pass other necessary data if needed
                    ),
              ),
              const SizedBox(height: 16),
              // 资格券列表
            ],
          ),
        ),
      );
    },
  );
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
      color: const Color(0xFFFFFFFF),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
