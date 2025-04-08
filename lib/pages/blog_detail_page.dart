import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import 'package:intl/intl.dart'; // 添加这行
import 'package:flutter_svg/flutter_svg.dart';

class BlogDetailPage extends StatefulWidget {
  final String title;
  final String content;
  final String author;
  final String time;
  final String type;

  const BlogDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.time,
    required this.type,
  });

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = []; // 修改为非 final，因为需要更新

  @override
  void initState() {
    super.initState();
    fetchComments(); // 页面初始化时获取评论
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

  Future<void> fetchComments() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getComments),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"blogId": '67e67fab599ee1a31e66b06b'}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        setState(() {
          comments = data
              .map((item) => Comment(
                    author: item['user']['name'] ?? '',
                    content: item['content'] ?? '',
                    time: formatDateTime(item['createdAt'] ?? ''), // 修改这里
                    avatar: item['user']['avatar'] ?? '',
                    isReply: item['isReply'] ?? false,
                  ))
              .toList();
        });
      }
    } catch (e) {
      print('获取评论失败: $e');
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
        title: const Text(
          '你们好啊',
          style: TextStyle(color: Colors.black, fontSize: 16),
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
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '作者: ${widget.author}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '发布时间: ${widget.time}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (widget.type == 'hasAbstract') ...[
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
                        const SizedBox(height: 8),
                        Text(
                          widget.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const SizedBox(height: 16),

                        const Text(
                          '评论区',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
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
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFE6F7FF),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF1890FF),
                                  size: 18,
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
                                        '写点什么吧...',
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentItem(comment: comments[index]);
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

class Comment {
  final String author;
  final String content;
  final String time;
  final String avatar;
  final bool isReply;

  Comment({
    required this.author,
    required this.content,
    required this.time,
    required this.avatar,
    this.isReply = false,
  });
}

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            placeholderBuilder: (BuildContext context) => Container(
              padding: const EdgeInsets.all(30.0),
              child: const CircularProgressIndicator(),
            ),
          ),
          // CircleAvatar(
          //   radius: 20,
          //   backgroundColor: const Color(0xFFE6F7FF),
          //   backgroundImage:
          //       comment.avatar.isNotEmpty ? NetworkImage(comment.avatar) : null,
          //   child: comment.avatar.isEmpty
          //       ? const Icon(Icons.person, color: Color(0xFF1890FF))
          //       : null,
          // ),

          // Image.network(
          //   comment.avatar,
          //   width: 20,
          //   height: 20,
          //   fit: BoxFit.cover,
          // ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // const SizedBox(height: 2),
                Text(comment.content),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
