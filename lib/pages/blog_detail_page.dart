import 'package:flutter/material.dart';
import '../config/nft_api.dart';
import '../config/api.dart'; // 添加这行
import 'package:intl/intl.dart'; // 添加这行
import 'package:flutter_svg/flutter_svg.dart';

class BlogDetailPage extends StatefulWidget {
  final String id; // 添加 id 参数

  const BlogDetailPage({
    super.key,
    required this.id,
  });

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

// 在文件顶部添加 BlogInfo 类
class BlogInfo {
  final String title;
  final String createName;
  final String content;
  final String createdAt;
  final String type;
  final List<Comment> replies; // 修改为 List<Comment>

  BlogInfo({
    this.title = '',
    this.createName = '',
    this.content = '',
    this.createdAt = '',
    this.type = '',
    this.replies = const [], // 默认为空列表
  });

  factory BlogInfo.fromJson(Map<String, dynamic> json) {
    return BlogInfo(
      title: json['title'] ?? '',
      createName: json['createName'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = []; // 修改为非 final，因为需要更新
  BlogInfo blogInfo = BlogInfo(); // 修改这里

  void initState() {
    super.initState();
    fetchComments(); // 页面初始化时获取评论
    fetchBlogDetail();
  }

  String formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  Future<void> fetchBlogDetail() async {
    final response = await Api.get(NftApi.getBlogDetail(widget.id));
    if (response['success'] != false) {
      setState(() {
        blogInfo = BlogInfo.fromJson(response['data'] ?? {});
      });
    }
  }

  Future<void> fetchComments() async {
    final response = await Api.post(
      NftApi.getComments,
      data: {
        'blogId': widget.id, // 传入博客 ID
      },
    );
    if (response['success'] != false) {
      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        comments = data.map((item) {
          final List<Comment> replies =
              (item['replies'] as List<dynamic>? ?? [])
                  .map((reply) => Comment(
                      author: reply['user']['name'] ?? '',
                      content: reply['content'] ?? '',
                      time: formatDateTime(reply['createdAt'] ?? ''),
                      avatar: reply['user']['avatar'] ?? '',
                      isReply: true,
                      toUserName: reply['toUserName'] ?? '',
                      user: reply['user'] ?? {}))
                  //   Users(
                  //       data: reply['user'] ?? {}), // Create Users object
                  // ))
                  .toList();
          return Comment(
              author: item['user']['name'] ?? '',
              content: item['content'] ?? '',
              time: formatDateTime(item['createdAt'] ?? ''),
              avatar: item['user']['avatar'] ?? '',
              isReply: false,
              replies: replies,
              toUserName: item['toUserName'] ?? '',
              user: item['user'] ?? {} // Create Users object
              );
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SvgPicture.network(
              "https://api.dicebear.com/9.x/big-ears/svg",
              height: 36,
              width: 36,
              placeholderBuilder: (BuildContext context) => const Icon(
                Icons.person,
                size: 36,
                color: Color(0xFF1890FF),
              ),
            ),
            const SizedBox(width: 8), // 减小间距
            Expanded(
              child: Text(
                blogInfo.createName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1, // 限制一行
                overflow: TextOverflow.ellipsis, // 超出显示省略号
              ),
            ),
            const SizedBox(width: 8), // 减小间距
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1890FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, // 减小内边距
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '关注',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blogInfo.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (blogInfo.type == 'hasAbstract') ...[
                          // 或者根据实际情况判断是否有摘要
                          const Text(
                            '内容摘要',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 8),
                        // const Divider(),
                        // const SizedBox(height: 16),
                        // const Text(
                        //   '正文内容',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        Text(
                          blogInfo.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Text(
                              '${blogInfo.createdAt}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(
                          color: Color.fromARGB(68, 200, 207, 201),
                        ),
                        const Text(
                          '所有评论',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 添加评论输入提示框
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.network(
                                "https://api.dicebear.com/9.x/big-ears/svg",
                                height: 30,
                                width: 30,
                                placeholderBuilder: (BuildContext context) =>
                                    const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Color(0xFF1890FF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFE8E8E8),
                                      width: 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(20), // 增大圆角
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        '说点什么吧...',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 修改 ListView.builder 中的调用
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentItem(
                        comment: comments[index],
                        parentComment: null, // 顶层评论没有父评论
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '写点什么吧...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      setState(() {
                        comments.add(
                          Comment(
                            author: "当前用户",
                            content: _commentController.text,
                            time: DateTime.now().toString(),
                            avatar: "",
                          ),
                        );
                        _commentController.clear();
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1890FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    '发送',
                    style: TextStyle(color: Colors.white),
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

// 添加 User 类定义
class Users {
  final Map<String, dynamic> data;

  Users({
    required this.data,
  });

  String? get name => data['name'];
  String? get avatar => data['avatar'];
}

class Comment {
  final String author;
  final String content;
  final String time;
  final String avatar;
  final bool isReply;
  final String toUserName;
  final Map<String, dynamic>? user; // 直接使用 Map
  final List<Comment> replies; // 添加子评论列表

  Comment({
    required this.author,
    required this.content,
    required this.time,
    required this.avatar,
    this.toUserName = '',
    this.isReply = false,
    this.user,
    this.replies = const [], // 默认空列表
  });
}

// 修改 CommentItem 的属性定义
class CommentItem extends StatelessWidget {
  final Comment comment;
  final Comment? parentComment; // 改为 Comment? 类型
  const CommentItem({
    super.key,
    required this.comment,
    this.parentComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: comment.isReply ? 56 : 16,
            right: 16,
            top: 0,
            bottom: 28,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.network(
                comment.avatar,
                height: 30,
                width: 30,
                placeholderBuilder: (BuildContext context) => const Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF1890FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 8.0), // 在右侧添加 16 的间距
                        Text(
                          comment.time,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (comment.toUserName.isNotEmpty &&
                            comment.toUserName !=
                                parentComment?.user?['name']) ...[
                          Text(
                            '回复 ${comment.toUserName}: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            comment.content,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (comment.replies.isNotEmpty) ...[
          ...comment.replies.map(
            (reply) => CommentItem(
              comment: reply,
              parentComment: comment, // 传递当前评论作为父评论
            ),
          ),
        ],
      ],
    );
  }
}
