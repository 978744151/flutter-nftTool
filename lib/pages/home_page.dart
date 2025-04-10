import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import '../widgets/bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用 super.build
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部圆形轮廓图片
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.brown.shade800,
                // image: DecorationImage(
                //   image: AssetImage('assets/images/tunnel.jpg'),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: Center(
                child: Text(
                  '你们好呀',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 页面指示器
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 3,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // 功能区块
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFunctionCard(context, 'assets/images/icon1.png', '鱼写论坛',
                      () => print('鱼写论坛')),
                  _buildFunctionCard(context, 'assets/images/icon2.png', '数字藏品',
                      () => context.go('/shop')),
                  _buildFunctionCard(context, 'assets/images/icon3.png', '公告管理',
                      () => print('公告管理')),
                ],
              ),
            ),

            // 最新文章区域
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最新文章',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '查看更多 >',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // 文章列表
            _buildArticleCard(
              '你们好呀',
              '@蜗牛勇',
              '2025-03-28 17:34:49',
            ),
            _buildArticleCard(
              '哈哈哈哈',
              '@蜗牛勇',
              '2025-03-28 18:53:31',
            ),
            _buildArticleCard(
              '哈哈哈哈',
              '@蜗牛勇',
              '2025-03-28 18:53:31',
            ),
            _buildArticleCard(
              '哈哈哈哈',
              '@蜗牛勇',
              '2025-03-28 18:53:31',
            ),
            _buildArticleCard(
              '哈哈哈哈',
              '@蜗牛勇',
              '2025-03-28 18:53:31',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/create');
        },
        // backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        // mini:true
      ),
      // bottomNavigationBar: CustomBottomNavigation(
      //   currentIndex: 0,
      // ),
    );
  }

  Widget _buildFunctionCard(BuildContext context, String imagePath,
      String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 替换成实际的图片
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.image, color: Colors.orange),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(String title, String author, String time) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$author · $time',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
