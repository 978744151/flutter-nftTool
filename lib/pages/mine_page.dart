import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/storage.dart'; // 添加导入
import 'dart:convert'; // 添加这行
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/http_client.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with TickerProviderStateMixin {
  Map<dynamic, dynamic> userInfo = {};
  Map<dynamic, dynamic> followerInfo = {};
  late TabController _tabController;
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
    _tabController.addListener(() {
      // 当Tab切换时，可以在这里添加额外的逻辑
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // 设置状态栏颜色为页面背景颜色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.blue, // 状态栏背景色
        statusBarIconBrightness: Brightness.light, // 图标颜色（亮色）
      ),
    );

    _getToken();
    _loadMockData();
  }

  // 加载模拟数据
  void _loadMockData() {
    // 模拟我的藏品数据
    myCollectionsList = List.generate(
        10,
        (index) => {
              'id': 'coll$index',
              'name': '藏品 #${index.toString().padLeft(3, '0')}',
              'imageUrl': 'https://picsum.photos/200/300?random=$index',
              'price': '¥${(index * 10 + 10).toString()}',
              'date': '2023-08-${(index + 1).toString().padLeft(2, '0')}',
            });

    // 模拟我的盲盒数据
    myMysteryBoxesList = List.generate(
        5,
        (index) => {
              'id': 'box$index',
              'name': '盲盒 #${index.toString().padLeft(3, '0')}',
              'imageUrl': 'https://picsum.photos/200/300?random=${index + 20}',
              'price': '¥${(index * 20 + 30).toString()}',
              'date': '2023-09-${(index + 1).toString().padLeft(2, '0')}',
            });

    // 模拟售出藏品数据
    soldCollectionsList = List.generate(
        8,
        (index) => {
              'id': 'sold$index',
              'name': '售出藏品 #${index.toString().padLeft(3, '0')}',
              'imageUrl': 'https://picsum.photos/200/300?random=${index + 40}',
              'price': '¥${(index * 15 + 25).toString()}',
              'date': '2023-10-${(index + 1).toString().padLeft(2, '0')}',
              'buyer': '买家ID_${index + 100}',
            });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      }
    } catch (e) {
      print('获取用户信息失败: $e');
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
      child: Scaffold(
        body: SafeArea(
          top: false, // 不影响顶部
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 顶部信息区域 SliverAppBar
                SliverAppBar(
                  expandedHeight: 150.0, // 展开时的高度
                  pinned: true, // 固定在顶部
                  title: AnimatedOpacity(
                    opacity: _showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '持有资产',
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
                  flexibleSpace: FlexibleSpaceBar(
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
                            Colors.white,
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
                                userInfo!['avatar'],
                                height: 35,
                                width: 35,
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
                      color: Colors.white,
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
                              icon: Icons.card_membership,
                              iconColor: Colors.orange,
                              bgColor: Colors.orange[50]!,
                              label: '钱包',
                            ),
                            _buildSecondaryFunction(
                              icon: Icons.monetization_on,
                              iconColor: Colors.amber,
                              bgColor: Colors.amber[50]!,
                              label: '签到',
                            ),
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
                    color: Colors.white,
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                            height: 40,
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
                  ),
                ),

                // TabBar（悬浮到顶部）
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      indicatorWeight: 3,
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
                          color: Colors.white,
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
                          color: Colors.white,
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
                          color: Colors.white,
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
                    style: TextStyle(color: Colors.white, fontSize: 8),
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
                    style: TextStyle(color: Colors.white, fontSize: 8),
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
      backgroundColor: Colors.white,
      elevation: 20,
      clipBehavior: Clip.antiAliasWithSaveLayer, // 添加裁剪行为
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
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
                      '${item['name']} （共10份）',
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
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      // 生成随机ID
                      final id = '#${92300000 + (index * 123456) % 1000000}';
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
                                color: Colors.orange.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '未寄售/可合成',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '寄售价¥--',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                            const Text(
                              '来源: 空投',
                              style: TextStyle(
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

// 统计项组件
class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
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
      color: Colors.white, // TabBar的背景色
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
