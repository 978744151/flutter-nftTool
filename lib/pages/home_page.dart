import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../utils/http_client.dart';

import '../models/nft_category.dart';
import '../models/nft.dart';
import '../services/nft_service.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../widgets/red_book_card.dart';
import '../models/blog.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  bool get wantKeepAlive => true;

  List<NFTCategory> categories = [];
  List<NFT> nfts = [];
  bool isLoading = true;
  String currentCategory = '';
  int currentPage = 1;
  final int perPage = 10;
  final ScrollController _scrollController = ScrollController();
  List<Blog> blogs = [];

  @override
  void initState() {
    super.initState();
    fetchNFTs();
    fetchBlogs();
    _scrollController.addListener(_onScroll);
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> fetchBlogs() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await HttpClient.get('/blogs?page=1');

      if (!mounted) return;
      if (response['success']) {
        final List<dynamic> blogsData = response['data']['data'] ?? [];
        setState(() {
          blogs = blogsData.map((item) => Blog.fromJson(item)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
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
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchNFTs(loadMore: true);
    }
  }

  Future<void> fetchNFTs({bool loadMore = false}) async {
    if (!loadMore) {
      currentPage = 1;
    }
    try {
      final response = await HttpClient.get('/nfts?page=1&perPage=999');
      if (!mounted) return;
      final List<dynamic> nftsData = response['data']['data'] ?? [];

      setState(() {
        nfts = nftsData.map((item) => NFT.fromJson(item)).toList();
      });
      print('获取NFT成功: $nfts');
    } catch (e) {
      print('获取NFT失败: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFfffff),
      // 移除appBar,让内容区域扩展到状态栏
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: CustomScrollView(
        slivers: <Widget>[
          // 首先放置横幅，扩展到状态栏
          SliverToBoxAdapter(
            child: _buildTopBanner(),
          ),

          // 其余内容
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // 搜索框
                _buildSearchBar(),

                // 功能区
                _buildFunctionArea(),

                // 热门场景
                _buildHotScenes(),

                // 社区活动
                _buildBlogHotScenes(),

                // 底部空白
              ],
            ),
          ),
          SliverToBoxAdapter(
              child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.9, // 修改这里
            ),
            child: MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              controller: _scrollController, // 添加控制器
              key: const PageStorageKey(
                'message_grid',
              ), // 添加 key 保存状态
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(8),
              itemCount: blogs.length,
              itemBuilder: (context, index) {
                final blog = blogs[index];
                // 根据内容长度动态计算高度
                final contentLength = blog.title.length + blog.content.length;
                final randomHeight = 180.0 + (contentLength % 3) * 40;

                return RedBookCard(
                  avatar: '',
                  name: blog.createName,
                  title: blog.title,
                  content: blog.content,
                  time: blog.createdAt,
                  type: blog.type,
                  defaultImage: blog.defaultImage,
                  likes: 0,
                  comments: 0,
                  height: randomHeight,
                  id: blog.id,
                  user: blog.user,
                );
              },
            ),
          ))
        ],
      ),
    );
  }

  // 顶部横幅 - 修改为扩展到状态栏
  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      // 增加高度以覆盖状态栏
      // height: 165 + MediaQuery.of(context).padding.top,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB2CBF6),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 背景水印文字
          Positioned(
            right: 20,
            // 调整位置以适应状态栏
            top: 40 + MediaQuery.of(context).padding.top,
            child: Text(
              'ONCE',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),

          // 爱心图标
          Positioned(
            right: 20,
            // 调整位置以适应状态栏
            top: 10 + MediaQuery.of(context).padding.top,
            child: Icon(
              Icons.favorite,
              color: Colors.red[400],
              size: 40,
            ),
          ),

          // 主要内容
          Padding(
            // 调整内边距以适应状态栏
            padding: EdgeInsets.fromLTRB(
                20.0, 20.0 + MediaQuery.of(context).padding.top, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '欢迎来到 ONCE META',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '获取您的专属藏品',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('立即购买 >'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 搜索框
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.grey),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '公告: 回头望,鹿在朝藏品即将上线',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.density_medium,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // 功能区
  Widget _buildFunctionArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '发售日记',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  // 查看更多
                },
                child: const Text(
                  '查看更多 >',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : nfts.isEmpty
                  ? const Center(
                      child: Text('暂无数据'),
                    )
                  : SizedBox(
                      height: 110, // 根据内容调整高度
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: nfts.length,
                        itemBuilder: (context, index) {
                          final nft = nfts[index];
                          // 为每个NFT随机选择一个颜色
                          final colors = [
                            Colors.pink[100]!,
                            Colors.green[100]!,
                            Colors.blue[100]!,
                            Colors.orange[100]!,
                            Colors.purple[100]!
                          ];
                          final randomColor = colors[index % colors.length];

                          // 为每个NFT选择一个图标
                          final icons = [
                            Icons.image,
                            Icons.pets,
                            Icons.star,
                            Icons.favorite,
                            Icons.diamond
                          ];
                          final randomIcon = icons[index % icons.length];

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == nfts.length - 1 ? 0 : 12,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                // 这里填写你的点击事件逻辑，比如跳转详情页
                                context.go('/nftDetail/${nft.id}');
                              },
                              child: _buildFeatureBox(
                                nft.name,
                                randomIcon,
                                randomColor,
                                '¥${nft.price}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  // 功能小方块
  Widget _buildFeatureBox(
      String title, IconData icon, Color color, String price) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        image: nfts.isNotEmpty &&
                nfts.any((nft) => nft.name == title && nft.imageUrl.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(
                  nfts.firstWhere((nft) => nft.name == title).imageUrl,
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '限量发售',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
    );
  }

  // 功能图标
  Widget _buildFeatureIcon(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 25),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // 热门场景
  Widget _buildHotScenes() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '活动中心',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureIcon('合成中心', Icons.book, Colors.blue[50]!),
                _buildFeatureIcon('抽奖活动', Icons.lightbulb, Colors.yellow[50]!),
                _buildFeatureIcon('签到', Icons.favorite, Colors.pink[50]!),
                _buildFeatureIcon('邀请码', Icons.pin_invoke, Colors.purple[50]!),
              ],
            ),
          ),

          // const SizedBox(height: 12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     _buildSceneButton('校园语录', Icons.school),
          //     _buildSceneButton('表情包', Icons.image),
          //     _buildSceneButton('择偶市场', Icons.favorite),
          //   ],
          // ),
          // const SizedBox(height: 12),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     _buildSceneButton('广大社交', Icons.people),
          //     _buildSceneButton('粤语港', Icons.translate),
          //     _buildSceneButton('热搜', Icons.trending_up),
          //     _buildSceneButton('更多', Icons.more_horiz),
          //   ],
          // ),
        ],
      ),
    );
  }

  // 热门场景
  Widget _buildBlogHotScenes() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '社区论坛',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 场景按钮
  Widget _buildSceneButton(String title, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // 黑话词典
  Widget _buildDictionary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '黑话词典',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '精选流行网络用语',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '查看最新更多热门内容',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2F5E5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '一键查询',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
