import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordDictHomePage extends StatefulWidget {
  const WordDictHomePage({Key? key}) : super(key: key);

  @override
  State<WordDictHomePage> createState() => _WordDictHomePageState();
}

class _WordDictHomePageState extends State<WordDictHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部横幅 - 测试爱情人格
              _buildBanner(),

              // 搜索框
              _buildSearchBar(),

              // 功能区 - 语音翻译、AI、土味情话等
              _buildFunctionArea(),

              // 热门场景
              _buildHotScenes(),

              // 黑话词典
              _buildDictionary(),

              // 底部空白
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 底部导航栏
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark),
          label: '藏品',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline, size: 30),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: '社区',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }

  // 顶部横幅
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFB2F5E5), // 薄荷绿背景
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // 背景水印文字
          Positioned(
            right: 20,
            top: 40,
            child: Text(
              'MBTI',
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
            top: 10,
            child: Icon(
              Icons.favorite,
              color: Colors.red[400],
              size: 40,
            ),
          ),

          // 主要内容
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '测测你的恋爱人格',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '获取专属恋爱方案',
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
                  child: const Text('立即测试 >'),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '网络流行词搜索解释，比如"彩绘烤瓷杯"',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // 功能区
  Widget _buildFunctionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureBox('语音翻译', Icons.mic, Colors.pink[100]!),
              _buildFeatureBox('知识老师', Icons.school, Colors.green[100]!),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureIcon('集团教程', Icons.book, Colors.blue[50]!),
              _buildFeatureIcon('技能', Icons.lightbulb, Colors.yellow[50]!),
              _buildFeatureIcon('土味情话', Icons.favorite, Colors.pink[50]!),
              _buildFeatureIcon('黑话词典', Icons.menu_book, Colors.purple[50]!),
            ],
          ),
        ),
      ],
    );
  }

  // 功能小方块
  Widget _buildFeatureBox(String title, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
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
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '一键语音 轻松翻译',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                title == '知识老师' ? '24小时在线' : '',
                style: const TextStyle(fontSize: 12),
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
            child: Icon(icon, size: 20),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门场景',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSceneButton('校园语录', Icons.school),
              _buildSceneButton('表情包', Icons.image),
              _buildSceneButton('择偶市场', Icons.favorite),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSceneButton('广大社交', Icons.people),
              _buildSceneButton('粤语港', Icons.translate),
              _buildSceneButton('热搜', Icons.trending_up),
              _buildSceneButton('更多', Icons.more_horiz),
            ],
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
