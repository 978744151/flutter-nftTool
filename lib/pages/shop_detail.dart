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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // 初始化 nftInfo
    nftInfo = NftInfo(
      id: '',
      name: '',
      imageUrl: '',
      price: '',
      quantity: '',
    );
    fetchData();
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              final pixels = scrollNotification.metrics.pixels;
              // 根据滚动位置决定是否显示标题
              setState(() {
                _showTitle = pixels >= 200;
                _scrollProgress = (pixels / 200).clamp(0.0, 1.0);
              });
            }
            return true;
          },
          child: CustomScrollView(
            slivers: [
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
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  // 不显示 FlexibleSpaceBar 的标题
                  title: const SizedBox.shrink(),
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
                      // 居中的主图
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          child: isLoading
                              ? null
                              : Image.network(
                                  height: 280,
                                  nftInfo.imageUrl,
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
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '山海之灵·祥兽狂狂',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '总量',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  '10,000份',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '当前流通',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const Text(
                                  '0份',
                                  style: TextStyle(
                                    fontSize: 16,
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
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildConsignmentList(),
                    _buildCurrentDeals(),
                    _buildNFTDetails(),
                    _buildAnnouncements(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildConsignmentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white, // 直接
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('幻殇·月光 #${index.toString().padLeft(4, '0')}'),
            subtitle: Text('0x${index}d8f...3e2a'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${2.5 + index * 0.1} ETH'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(80, 20),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {},
                  child: const Text('购买'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentDeals() {
    return const Center(child: Text('当前成交'));
  }

  Widget _buildNFTDetails() {
    return const Center(child: Text('NFT详情'));
  }

  Widget _buildAnnouncements() {
    return const Center(child: Text('相关公告'));
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
