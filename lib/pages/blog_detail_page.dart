import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/comment_api.dart';
import 'package:intl/intl.dart'; // 添加这行
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/http_client.dart';

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
  // 添加遮罩层控制变量
  bool _showOverlay = false;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _currentCommentId; // 添加评论ID变量
  String? _currentReplyTo; // 添加回复用户ID变量
  List<Comment> comments = [];
  BlogInfo blogInfo = BlogInfo();
  String _replyToName = ''; // 添加这行

  @override
  void initState() {
    super.initState();
    _commentFocusNode.addListener(_handleFocusChange);
    fetchComments();
    fetchBlogDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
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
    if (!mounted) return;

    try {
      final response = await HttpClient.get(NftApi.getBlogDetail(widget.id));
      if (!mounted) return; // Check mounted again after await

      if (response['success'] != false) {
        setState(() {
          blogInfo = BlogInfo.fromJson(response['data'] ?? {});
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Handle error if needed
    }
  }

  Future<void> fetchComments() async {
    if (!mounted) return;

    try {
      final response = await HttpClient.post(NftApi.getComments, body: {
        'blogId': widget.id,
      });
      if (!mounted) return; // Check mounted again after await

      if (response['success'] != false) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          comments = data.map((item) {
            final List<Comment> replies =
                (item['replies'] as List<dynamic>? ?? [])
                    .map((reply) => Comment(
                        id: reply['id'] ?? '', // 修改：直接获取评论 ID
                        author: reply['user']['name'] ?? '',
                        content: reply['content'] ?? '',
                        time: formatDateTime(reply['createdAt'] ?? ''),
                        avatar: reply['user']['avatar'] ?? '',
                        isReply: true,
                        toUserName: reply['toUserName'] ?? '',
                        likeCount: reply['likeCount'] ?? 0,
                        isLiked: reply['isLiked'], // 修改这行
                        user: reply['user'] ?? {}))
                    .toList();
            return Comment(
                id: item['id'] ?? '', // 修改：直接获取评论 ID
                author: item['user']['name'] ?? '',
                content: item['content'] ?? '',
                time: formatDateTime(item['createdAt'] ?? ''),
                avatar: item['user']['avatar'] ?? '',
                isReply: false,
                replies: replies,
                toUserName: item['toUserName'] ?? '',
                // ... 其他属性保持不变 ...
                likeCount: item['likeCount'] ?? 0,
                isLiked: item['isLiked'], // 修改这行
                user: item['user'] ?? {});
          }).toList();
        });
        setState(() {
          _currentCommentId = null;
          _currentReplyTo = null;
          _replyToName = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Handle error if needed
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      final response = await HttpClient.post(
        NftApi.createComment,
        body: {
          'blogId': widget.id,
          'content': _commentController.text,
        },
      );

      if (response['success'] == true) {
        _commentController.clear();
        // 重新获取评论列表
        fetchComments();
      }
    } catch (e) {
      // 错误处理
    }
  }

  Future<void> _replyComment(String commentId, String replyTo) async {
    if (_commentController.text.isEmpty) return;

    try {
      if (commentId.isEmpty) {
        return;
      }
      final response = await HttpClient.post(
        '/comment/reply',
        body: {
          'blogId': widget.id,
          'commentId': commentId,
          'content': _commentController.text,
          'replyTo': replyTo,
        },
      );

      if (response['success'] == true) {
        _commentController.clear();
        fetchComments();
      }
    } catch (e) {
      print('Reply error: $e');
    }
  }

  // 添加焦点监听处理
  void _handleFocusChange() {
    setState(() {
      _showOverlay = _commentFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // 在 AppBar 中修改返回按钮的处理

          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/message');
              }
              // if (Navigator.canPop(context)) {
              //   // 添加检查
              //   Navigator.pop(context);
              // }
            },
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
                  // backgroundColor: const Color.fromARGB(255, 199, 46, 102),
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
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(children: [
          Column(
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
                                  blogInfo.createdAt,
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
                                    placeholderBuilder:
                                        (BuildContext context) =>
                                            const Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _replyToName = '';
                                          _currentCommentId = null;
                                          _currentReplyTo = null;
                                        });
                                        FocusScope.of(context)
                                            .requestFocus(_commentFocusNode);
                                      },
                                      child: Container(
                                        height: 38,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFFE8E8E8),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        child: const Row(
                                          children: [
                                            Text(
                                              '说点什么吧...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
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
                            parentComment: null,
                            onReply: (commentId, replyTo, replyToName) {
                              // 修改这里，添加 replyToName 参数
                              FocusScope.of(context)
                                  .requestFocus(_commentFocusNode);
                              setState(() {
                                _currentCommentId = commentId;
                                _currentReplyTo = replyTo;
                                _replyToName = replyToName; // 使用传入的用户名
                              });
                            },
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
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -1),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              // 添加遮罩层
            ],
          ),

          // 输入框固定在底部，始终保持在最顶层
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                if (_showOverlay)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showOverlay = false;
                        _currentCommentId = null;
                        _currentReplyTo = null;
                        _replyToName = '';
                      });
                    },
                    child: Container(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.5),
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom -
                          80,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
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
                          focusNode: _commentFocusNode, // 添加 focusNode
                          textInputAction: TextInputAction.send, // 添加这行
                          onSubmitted: (value) {
                            // 添加这行
                            if (_currentCommentId != null &&
                                _currentReplyTo != null) {
                              _replyComment(
                                  _currentCommentId!, _currentReplyTo!);
                            } else {
                              _sendComment();
                            }
                            setState(() {
                              _currentCommentId = null;
                              _currentReplyTo = null;
                              _replyToName = '';
                            });
                          },
                          decoration: InputDecoration(
                            hintText: _replyToName.isEmpty
                                ? '写点什么吧...'
                                : '回复 @$_replyToName',
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
                      // 修改发送按钮的 onPressed 处理
                      TextButton(
                        onPressed: () {
                          if (_currentCommentId != null &&
                              _currentReplyTo != null) {
                            _replyComment(_currentCommentId!, _currentReplyTo!);
                          } else {
                            _sendComment();
                          }
                          // 隐藏键盘
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _currentCommentId = null;
                            _currentReplyTo = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          '发送',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
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
  final String id; // 添加评论ID
  final String author;
  final String content;
  final String time;
  final String avatar;
  final bool isReply;
  final String toUserName;
  final Map<String, dynamic>? user; // 直接使用 Map
  final List<Comment> replies; // 添加子评论列表
  final int? likeCount; // 新增
  final bool isLiked; // 新增
  Comment({
    required this.id, // 添加到构造函数
    required this.author,
    required this.content,
    required this.time,
    required this.avatar,
    this.toUserName = '',
    this.isReply = false,
    this.user,
    this.replies = const [], // 默认空列表
    this.likeCount, // 新增
    this.isLiked = false, // 新增
  });
}

// 修改 CommentItem 类的定义
class CommentItem extends StatelessWidget {
  final Comment comment;
  final Comment? parentComment;
  final Function(String, String, String)? onReply; // 修改回调函数类型，添加用户名参数

  const CommentItem({
    super.key,
    required this.comment,
    this.parentComment,
    this.onReply,
  });
  // 修改 _handleLike 方法
  Future<void> _handleLike(BuildContext context) async {
    try {
      final response = await HttpClient.post(
        '/comment/like',
        body: {'commentId': comment.id},
      );

      if (response['code'] == 200 || response['success'] == true) {
        // 修改这行
        if (context.mounted) {
          context
              .findAncestorStateOfType<_BlogDetailPageState>()
              ?.fetchComments();
        }
      }
    } catch (e) {
      print('Like error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (onReply != null) {
              onReply!(
                comment.id,
                comment.user?['_id'] ?? '',
                comment.author, // 传递当前评论的作者名
              );
            }
          },
          child: Padding(
            // 将 Container 改为 Padding 以优化点击响应
            padding: EdgeInsets.only(
                left: comment.isReply ? 56 : 16,
                right: 6,
                top: comment.isReply ? 10 : 16, // 增加上下内边距
                bottom: comment.isReply ? 10 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.network(
                  comment.avatar,
                  height: comment.isReply ? 30 : 38, // 根据是否为回复设置不同高度
                  width: comment.isReply ? 30 : 38, // 根据是否为回复设置不同宽度
                  placeholderBuilder: (BuildContext context) => Icon(
                    Icons.person,
                    size: comment.isReply ? 30 : 38, // 占位图标也相应调整大小
                    color: const Color(0xFF1890FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, //
                        children: [
                          Text(
                            comment.author,
                            style: TextStyle(
                              color: Colors.grey[600],
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
                          SizedBox(
                            width: 40,
                            height: 35,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.start, // 添加这行
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0), // 添加顶部内边距，让心形向下移动
                                  child: GestureDetector(
                                    onTap: () => _handleLike(context),
                                    child: Icon(
                                      comment.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: comment.isLiked
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (comment.likeCount != null &&
                                    comment.likeCount! > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Text(
                                      '${comment.likeCount}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      // const SizedBox(height: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (comment.replies.isNotEmpty) ...[
          ...comment.replies.map(
            (reply) => CommentItem(
              comment: reply,
              parentComment: comment,
              onReply: onReply,
            ),
          ),
        ],
      ],
    );
  }
}
