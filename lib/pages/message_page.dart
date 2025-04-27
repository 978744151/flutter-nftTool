import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../utils/http_client.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/event_bus.dart';
import 'dart:async';
import '../widgets/loading_indicator_widget.dart';

class Blog {
  final String id;
  final String title;
  final String content;
  final String createName;
  final String createdAt;
  final String type;
  final String defaultImage;
  final Map<String, dynamic>? user; // 直接使用 Map

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.createName,
    required this.createdAt,
    required this.type,
    required this.defaultImage,
    this.user,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createName: json['createName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      type: json['type'] ?? '',
      defaultImage: json['defaultImage'] ?? '',
      user: json['user'], // 直接使用 Map
    );
  }
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with AutomaticKeepAliveClientMixin {
  List<Blog> blogs = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription _subscription; // 添加这一行

  @override
  void initState() {
    super.initState();

    fetchBlogs();

    // 监听博客创建事件
    _subscription = eventBus.on<BlogCreatedEvent>().listen((_) {
      fetchBlogs();
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // 取消订阅
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

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
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false, // 添加此行防止键盘弹出导致布局问题

          // backgroundColor:
          // const Color.fromARGB(110, 238, 232, 230), // 取消注释并设置为白色
          backgroundColor: const Color(0xFFF9f9f9),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AppBar(
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFFFFF),
                  title: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _TabItem(text: '关注', isActive: false),
                            _TabItem(text: '推荐', isActive: true),
                            _TabItem(text: '最新', isActive: false),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search,
                              color: Color(0xFF8C8C8C)),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          body: isLoading
              ? const LoadingIndicatorWidget()
              : RefreshIndicator(
                  onRefresh: fetchBlogs, // 确保这里连接到 fetchBlogs
                  child: blogs.isEmpty
                      ? ListView(
                          // 将 Center 改为 ListView 以支持下拉刷新
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: Text('暂无数据'),
                              ),
                            ),
                          ],
                        )
                      : CustomScrollView(
                          controller: _scrollController, // 添加控制器
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                                child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height *
                                    0.9, // 修改这里
                              ),
                              child: Column(
                                children: [
                                  MasonryGridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                      final contentLength = blog.title.length +
                                          blog.content.length;
                                      final randomHeight =
                                          180.0 + (contentLength % 3) * 40;

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
                                ],
                              ),
                            ))
                          ],
                        ))

          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {},
          //   backgroundColor: const Color(0xFF1890FF),
          //   child: const Icon(Icons.add, color:  const Color(0xFFFFFFFF)),
          //   elevation: 2,
          // ),
          // bottomNavigationBar: CustomBottomNavigation(
          //   currentIndex: 2,
          // ),
          ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String text;
  final bool isActive;

  const _TabItem({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isActive ? const Color(0xFF333333) : const Color(0xFF8C8C8C),
        fontSize: isActive ? 18 : 16,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final String id; // 添加 id 参数
  final String avatar;
  final String name;
  final String title;
  final String content;
  final String time;
  final String type;
  final int likes;
  final int comments;

  const MessageCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.title,
    required this.content,
    required this.time,
    required this.type,
    required this.likes,
    required this.comments,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        context.go('/message/messageDetail/$id');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE6F7FF),
                    child: avatar.isEmpty
                        ? const Icon(Icons.person, color: Color(0xFF1890FF))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Color(0xFF1890FF),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(content, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.thumb_up_outlined,
                    count: likes,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.comment_outlined,
                    count: comments,
                    onPressed: () {},
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF8C8C8C),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8C8C8C)),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class RedBookCard extends StatelessWidget {
  final String avatar;
  final String name;
  final String title;
  final String content;
  final String time;
  final String id;
  final String type;
  final String defaultImage;
  final int likes;
  final int comments;
  final double height; // Add this parameter
  final Map<String, dynamic>? user; // 直接使用 Map

  const RedBookCard({
    super.key,
    required this.avatar,
    this.user,
    required this.id,
    required this.name,
    required this.defaultImage,
    required this.title,
    required this.content,
    required this.time,
    required this.type,
    required this.likes,
    required this.comments,
    this.height = 200, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/message/messageDetail/$id');
      },
      child: Card(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                image: defaultImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(defaultImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: defaultImage.isEmpty
                  ? const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.network(
                        user!['avatar'],
                        height: 15, // 根据是否为回复设置不同高度
                        width: 15, // 根据是否为回复设置不同宽度
                      ),
                      // CircleAvatar(
                      //   radius: 10,
                      //   backgroundColor: const Color(0xFFE6F7FF),
                      //   child: avatar.isEmpty
                      //       ? const Icon(
                      //           Icons.person,
                      //           color: Color(0xFF1890FF),
                      //           size: 14,
                      //         )
                      //       : null,
                      // ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const Icon(Icons.favorite_border, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        likes.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
