import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/nft_category.dart';
import '../models/nft.dart';
import '../services/nft_service.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ShopPage extends StatefulWidget {
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with AutomaticKeepAliveClientMixin {
  bool _isGridView = true;

  @override
  bool get wantKeepAlive => true; // 添加这行

  List<NFTCategory> categories = [];
  List<NFT> nfts = [];
  bool isLoading = true;
  String currentCategory = '';
  int currentPage = 1;
  final int perPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchNFTs(loadMore: true);
    }
  }

  Future<void> fetchCategories() async {
    try {
      final categories = await NFTService.getCategories();
      setState(() {
        this.categories = categories;
        if (categories.isNotEmpty) {
          currentCategory = categories[0].id;
          fetchNFTs();
        }
      });
    } catch (e) {
      print('获取分类失败: $e');
    }
  }

  Future<void> fetchNFTs({bool loadMore = false}) async {
    if (!loadMore) {
      currentPage = 1;
    }
    try {
      final nftList = await NFTService.getNFTs(
        category: currentCategory,
        page: currentPage,
        perPage: perPage,
      );
      setState(() {
        print('获取NFT成功: $nftList');
        if (loadMore) {
          nfts.addAll(nftList);
          currentPage++;
        } else {
          nfts = nftList;
        }
        isLoading = false;
      });
    } catch (e) {
      print('获取NFT失败: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用父类的 build 方法
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  // 添加 Center 包裹
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center, // 文本垂直居中
                    decoration: InputDecoration(
                      isDense: true, // 使输入框更紧凑
                      hintText: '搜索藏品',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
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
            PopupMenuButton<String>(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text('按热度',
                        style: TextStyle(color: Colors.black87, fontSize: 14)),
                    Icon(Icons.arrow_drop_down, color: Colors.black87),
                  ],
                ),
              ),
              onSelected: (String value) {
                // 处理排序选择
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'hot',
                  child: Text('按热度'),
                ),
                PopupMenuItem<String>(
                  value: 'price',
                  child: Text('按价格'),
                ),
                PopupMenuItem<String>(
                  value: 'latest',
                  child: Text('最新挂单'),
                ),
              ],
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
      ),
      body: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF), // 强制白色背景
          body: RefreshIndicator(
            onRefresh: () async {
              // 刷新所有数据
              await Future.delayed(Duration(seconds: 1));
              await Future.wait([
                fetchCategories(),
              ]);
            },
            color: Theme.of(context).primaryColor, // 修改进度条颜色
            strokeWidth: 3.0, // 调整进度条粗细
            displacement: 40.0, // 触发刷新的下拉距离
            child: Column(
              children: [
                // 分类列表
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category.id == currentCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentCategory = category.id;
                            isLoading = true;
                            fetchNFTs();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFFFFFF)
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // NFT列表
                Expanded(
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: const LoadingIndicator(
                              indicatorType: Indicator.lineScaleParty,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : _isGridView
                          ? GridView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: nfts.length,
                              itemBuilder: (context, index) {
                                final nft = nfts[index];
                                return GestureDetector(
                                  onTap: () {
                                    // 处理点击事件
                                    //   // 根据需求选择抛出异常或使用默认值
                                    context.go('/shop/detail/${nft.id}');
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                                color: const Color(0xFFFFFFFF),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                                child: Image.network(
                                                  nft.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: Colors.grey[100],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  nft.name,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '¥${nft.price}',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFFFF4D4F),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        '库存 ${nft.stock}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              controller: _scrollController,
                              itemCount: nfts.length,
                              itemBuilder: (context, index) {
                                final nft = nfts[index];
                                return Card(
                                  color: const Color(0xFFFFFFFF),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  elevation: 0.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        // 图片
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            nft.imageUrl,
                                            width: 80,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: 80,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // 标题和库存
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nft.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '数量: ${nft.stock}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 价格
                                        Text(
                                          '¥${nft.price}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
            // bottomNavigationBar: CustomBottomNavigation(currentIndex: 1),
          )),
    );
  }
}
