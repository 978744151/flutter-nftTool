import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/storage.dart'; // 添加导入
import 'dart:convert'; // 添加这行
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/http_client.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NFT {
  final String id;
  final String name;
  final String imageUrl;
  final String price; // 改为 String 类型
  final String stock; // 改为 String 类型
  final String category;

  NFT({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory NFT.fromJson(Map<String, dynamic> json) {
    return NFT(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      stock: json['stock']?.toString() ?? '0',
      category: json['category']?.toString() ?? '',
    );
  }
}

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with TickerProviderStateMixin {
  Map<dynamic, dynamic> userInfo = {};
  Map<dynamic, dynamic> userProfile = {};
  Map<dynamic, dynamic> followerInfo = {};
  Map<dynamic, dynamic> pointsInfo = {};
  Map<dynamic, dynamic> stats = {};

  late TabController _tabController;
  late ScrollController _scrollController; // 添加滚动控制器
  List<Map<String, dynamic>> myCollectionsList = [];
  List<Map<String, dynamic>> myMysteryBoxesList = [];
  List<Map<String, dynamic>> soldCollectionsList = [];
  bool _showTitle = false; // 添加标题显示控制
  bool isLoading = true;
  double _scrollProgress = 0.0; // 添加滚动进度变量

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController(); // 初始化滚动控制器

    // 监听滚动位置
    _scrollController.addListener(_updateScrollState);

    _tabController.addListener(() {
      // 当Tab切换时，根据索引调用不同的接口
      if (!_tabController.indexIsChanging) {
        // 切换Tab时，强制设置_showTitle为false
        if (_showTitle) {
          setState(() {
            // _showTitle = false;
          });
        }

        switch (_tabController.index) {
          case 0: // 我的藏品
            fetchProfileCollections(userInfo['_id']);
            break;
          case 1: // 我的盲盒
            fetchProfileMysteryBox(userInfo['_id']);
            break;
          case 2: // 售出藏品
            fetchProfilSalesList(userInfo['_id']);
            break;
        }
      }
    });
    // 设置状态栏颜色为页面背景颜色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 状态栏颜色（透明）
        statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色（黑色）
        statusBarBrightness: Brightness.light, // 状态栏亮度（亮色背景）
        systemNavigationBarColor: const Color(0xFFFFFFFF), // 导航栏颜色
        systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标颜色
      ),
    );

    _getToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose(); // 释放滚动控制器
    super.dispose();
  }

  Future<void> _getToken() async {
    if (!mounted) return;
    try {
      final userInfoJson = await Storage.getString('userInfo');
      if (userInfoJson != null) {
        setState(() {
          userInfo = json.decode(userInfoJson);
        });
        fetchFollowInfo(userInfo['_id']);
        fetchProfile(userInfo['_id']);
        fetchProfileCollections(userInfo['_id']);
        fetchProfileMysteryBox(userInfo['_id']);
        fetchProfilSalesList(userInfo['_id']);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }

// 添加获取关注信息的方法
  Future<void> fetchProfile(id) async {
    if (!mounted) return;
    try {
      final response = await HttpClient.get('/profile');
      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          userProfile = response['data'];
          stats = response['data'] ?? response['data']['stats'];
          pointsInfo = response['data'] ?? response['data']['pointsInfo'];
        });
      }
    } catch (e) {
      print('获取信息失败: $e');
    }
  }

  // 添加获取藏品的方法
  Future<void> fetchProfileCollections(id) async {
    if (!mounted) return;
    try {
      final response = await HttpClient.get('/nfts/user/collect');
      if (!mounted) return;

      if (response['success'] == true) {
        print(response['success'] == true);
        final List<dynamic> list = response['data'] ?? [];
        setState(() {
          // myCollectionsList = list
          // myCollectionsList = response['data'] ?? [];
          myCollectionsList = List<Map<String, dynamic>>.from(list);
        });
      }
    } catch (e) {
      print('获取关信息失败: $e');
    }
  }

// 添加获盲盒的方法
  Future<void> fetchProfileMysteryBox(id) async {
    if (!mounted) return;
    try {
      final response = await HttpClient.get('/profile/mystery-boxes');
      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          myMysteryBoxesList = response['data'] ?? [];
        });
      }
    } catch (e) {
      print('获取关信息失败: $e');
    }
  }

  // 添加获盲盒的方法
  Future<void> fetchProfilSalesList(id) async {
    if (!mounted) return;
    try {
      final response = await HttpClient.get('/profile/sales');
      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          soldCollectionsList = response['data'] ?? [];
        });
      }
    } catch (e) {
      print('获取关信息失败: $e');
    }
  }

// 添加获取关注信息的方法
  Future<void> fetchFollowInfo(id) async {
    if (!mounted) return;
    try {
      final response = await HttpClient.get('/follow/follow-info/$id');
      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          followerInfo = response['data'];
        });
      }
    } catch (e) {
      print('获取关注信息失败: $e');
    }
  }

  // 添加滚动位置更新方法
  void _updateScrollState() {
    final scrollProgress = _scrollController.position.pixels / 150.0;
    final shouldShowTitle = scrollProgress > 0.5;

    if (_showTitle != shouldShowTitle ||
        _scrollProgress != scrollProgress.clamp(0.0, 1.0)) {
      setState(() {
        _scrollProgress = scrollProgress.clamp(0.0, 1.0);
        _showTitle = shouldShowTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // 强制白色背景

      body: RefreshIndicator(
        onRefresh: () async {
          // 刷新所有数据
          await Future.wait([
            fetchProfile(userInfo['_id']),
            fetchFollowInfo(userInfo['_id']),
            fetchProfileCollections(userInfo['_id']),
            fetchProfileMysteryBox(userInfo['_id']),
            fetchProfilSalesList(userInfo['_id']),
          ]);
        },
        child: SafeArea(
          top: false, // 不影响顶部
          child: NestedScrollView(
            controller: _scrollController, // 使用滚动控制器
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final double statusBarHeight = MediaQuery.of(context).padding.top;
              return [
                // 顶部信息区域 SliverAppBar
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Color(0xFFB2CBF6),
                  expandedHeight: 150.0, // 减小展开高度
                  toolbarHeight: 56, // 固定工具栏高度，不再使用状态栏高度
                  collapsedHeight: 56, // 固定折叠高度，确保足够空间显示标题
                  pinned: true, // 固定在顶部
                  floating: true, // 保持浮动特性
                  snap: false,
                  title: AnimatedOpacity(
                    opacity: _showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: // 顶部用户信息
                        SizedBox(
                      height: 42, // 固定高度，不再根据屏幕大小动态调整
                      child: Row(
                        children: [
                          // 用户头像
                          SvgPicture.network(
                            userInfo['avatar'] ??
                                'https://api.dicebear.com/9.x/avataaars/svg?seed=Felix',
                            height: 35, // 固定头像大小
                            width: 35,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.grey),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // 用户名和等级 - 简化为只显示用户名
                          Expanded(
                            child: Text(
                              userInfo['name'] ?? '用户',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 右侧图标
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.headset_mic_outlined),
                                onPressed: () {},
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined),
                                onPressed: () {},
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    expandedTitleScale: 1.0, // 防止标题缩放
                    stretchModes: [
                      StretchMode.zoomBackground, // 背景放大（拉伸时）
                      StretchMode.blurBackground, // 背景模糊（拉伸时）
                    ],
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFB2CBF6),
                            const Color(0xFFFFFFFF),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          // 顶部用户信息
                          Row(
                            children: [
                              // 用户头像
                              SvgPicture.network(
                                userInfo['avatar'] ??
                                    'https://api.dicebear.com/9.x/avataaars/svg?seed=Felix',
                                height: 35,
                                width: 35,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person,
                                        color: Colors.grey),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              // 用户名和等级
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userInfo['name'] ?? '用户',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.verified_user,
                                                  size: 12,
                                                  color: Colors.blue[700]),
                                              const SizedBox(width: 2),
                                              Text(
                                                '会员',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.blue[700]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _StatItem(
                                            count:
                                                followerInfo['followingCount']
                                                        ?.toString() ??
                                                    '0',
                                            label: '关注'),
                                        const SizedBox(width: 16),
                                        _StatItem(
                                            count:
                                                followerInfo['followersCount']
                                                        ?.toString() ??
                                                    '0',
                                            label: '粉丝'),
                                        const SizedBox(width: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // 右侧图标
                              Row(
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.headset_mic_outlined),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.settings_outlined),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // 主要功能区
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMainFunction(Icons.access_time, '历史记录'),
                              _buildMainFunction(Icons.star_border, '收藏'),
                              _buildMainFunction(Icons.person_add, '关注'),
                              _buildMainFunction(Icons.people, '粉丝'),
                              _buildMainFunction(Icons.message, '消息',
                                  hasNotification: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 二级功能区
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[100]!,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                        bottom: BorderSide(
                          color: Colors.grey[100]!,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSecondaryFunction(
                              icon: Icons.shopping_bag_outlined,
                              iconColor: Colors.blue,
                              bgColor: Colors.blue[50]!,
                              label: '我的订单',
                            ),
                            _buildSecondaryFunction(
                              icon: Icons.monetization_on,
                              iconColor: Colors.orange,
                              bgColor: Colors.orange[50]!,
                              label: '钱包',
                            ),
                            _buildSecondaryFunction(
                                icon: Icons.card_membership,
                                iconColor: Colors.amber,
                                bgColor: Colors.amber[50]!,
                                label: '签到',
                                hasTag: true),
                            _buildSecondaryFunction(
                              icon: Icons.card_giftcard,
                              iconColor: Colors.amber,
                              bgColor: Colors.orange[50]!,
                              label: '积分兑换',
                            ),
                            _buildSecondaryFunction(
                              icon: Icons.share,
                              iconColor: Colors.red,
                              bgColor: Colors.red[50]!,
                              label: '分享app',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 藏品标题
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '持有资产',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 60),
                        // 替换原来的IconButton为搜索框
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              // 添加 Center 包裹
                              child: TextField(
                                textAlignVertical:
                                    TextAlignVertical.center, // 文本垂直居中
                                decoration: InputDecoration(
                                  isDense: true, // 使输入框更紧凑
                                  hintText: '搜索藏品',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    // 调整图标约束
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, // 垂直内边距设为0
                                    horizontal: 8, // 水平内边距
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ), // 固定在顶部
                ),

                // TabBar（悬浮到顶部）
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 5,
                      tabs: const [
                        Tab(text: '我的藏品'),
                        Tab(text: '我的盲盒'),
                        Tab(text: '售出藏品'),
                      ],
                    ),
                  ),
                  pinned: true, // 固定在顶部
                ),
              ];
            },
            // 底部TabBarView
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildMyCollections(),
                _buildMyMysteryBoxes(),
                _buildSoldCollections(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 我的藏品列表
  Widget _buildMyCollections() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimationLimiter(
      child: myCollectionsList.isEmpty
          ? const Center(child: Text('暂无藏品'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: myCollectionsList.length,
              itemBuilder: (context, index) {
                final item = myCollectionsList[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          _showNftDetailDialog(item);
                        },
                        child: Card(
                          elevation: 2,
                          color: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  item['imageUrl'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
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

  // 我的盲盒列表 - 改为GridView
  Widget _buildMyMysteryBoxes() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimationLimiter(
      child: myMysteryBoxesList.isEmpty
          ? const Center(child: Text('暂无盲盒'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: myMysteryBoxesList.length,
              itemBuilder: (context, index) {
                final item = myMysteryBoxesList[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          _showNftDetailDialog(item);
                        },
                        child: Card(
                          elevation: 2,
                          color: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  item['imageUrl'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
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

  // 售出藏品列表 - 改为GridView
  Widget _buildSoldCollections() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimationLimiter(
      child: soldCollectionsList.isEmpty
          ? const Center(child: Text('暂无售出记录'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: soldCollectionsList.length,
              itemBuilder: (context, index) {
                final item = soldCollectionsList[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          _showNftDetailDialog(item);
                        },
                        child: Card(
                          elevation: 2,
                          color: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  item['imageUrl'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _buildMainFunction(IconData icon, String label,
      {bool hasNotification = false}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 28),
            if (hasNotification)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style:
                        TextStyle(color: const Color(0xFFFFFFFF), fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSecondaryFunction({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    bool hasTag = false,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            if (hasTag)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '每日',
                    style:
                        TextStyle(color: const Color(0xFFFFFFFF), fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBottomFunction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showNftDetailDialog(Map<String, dynamic> item) {
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
        final List<dynamic> allEditions = item['editions'] ?? [];
        final List<dynamic> filteredEditions = allEditions.where((edition) {
          final status = edition['status'];
          return status == 2 || status == 3;
        }).toList();

        final int editionsCount = filteredEditions.length;

        return FractionallySizedBox(
          heightFactor: 0.7, // 弹框高度为屏幕高度的80%
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 添加一个小横条作为拖动指示器
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['name']} （共${editionsCount}份）',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 资格券列表
                Expanded(
                  child: filteredEditions.isEmpty
                      ? Center(child: Text('没有符合条件的资产'))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: editionsCount,
                          itemBuilder: (context, index) {
                            final edition = filteredEditions[index];
                            // 获取版本属性
                            final id = edition['tokenId'] ?? '#${index + 1}';
                            String statusText = '';
                            Color statusColor = Colors.orange;

                            // 根据status值设置状态文本和颜色
                            switch (edition['status']) {
                              case 2:
                                statusText = '未寄售';
                                statusColor = Colors.orange;
                                break;
                              case 3:
                                statusText = '已寄售';
                                statusColor = Colors.green;
                                break;
                              default:
                                statusText = '未知状态';
                                statusColor = Colors.grey;
                            }

                            final price = edition['price'];
                            final listingPrice =
                                price != null ? '寄售价¥$price' : '寄售价¥--';
                            final source = edition['source'] ?? '空投';

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    id.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    listingPrice,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '来源: $source',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 修改统计项组件以支持小屏幕
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final bool smallScreen;

  const _StatItem(
      {required this.count, required this.label, this.smallScreen = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: smallScreen ? 12 : 14,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: smallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }
}

// 修改SliverAppBarDelegate类
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
      color: const Color(0xFFFFFFFF), // 添加白色背景
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// 添加资产头部委托类
class _AssetsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget _widget;
  final double _statusBarHeight;

  _AssetsHeaderDelegate(this._widget, this._statusBarHeight);

  @override
  double get minExtent => 62.0; // Always include status bar height

  @override
  double get maxExtent => 62.0; // Always include status bar height

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Always add the status bar padding to prevent overlap
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          // Status bar spacer
          // Actual content
          Expanded(child: _widget),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_AssetsHeaderDelegate oldDelegate) {
    return _statusBarHeight != oldDelegate._statusBarHeight ||
        _widget != oldDelegate._widget;
  }
}
