// lib/pages/mine_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加这行导入
import 'package:go_router/go_router.dart';
import 'package:getwidget/getwidget.dart';

class MinePage extends StatelessWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 设置状态栏颜色与顶部背景一致
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.green.shade100, // 与顶部渐变色起始颜色一致
      statusBarIconBrightness: Brightness.dark, // 状态栏图标为深色
    ));

    return Scaffold(
      backgroundColor: Colors.green.shade100, // 设置整个页面背景色
      body: SafeArea(
        child: Column(
          children: [
            // 顶部信息区域
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green.shade100, Colors.green.shade50],
                ),
              ),
              child: Column(
                children: [
                  // 顶部导航栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '我的',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner_outlined),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 用户信息
                  Row(
                    children: [
                      GFAvatar(
                        backgroundImage: const NetworkImage(
                          'https://api.dicebear.com/9.x/big-ears/svg',
                        ),
                        size: 50,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hi, 191*******12',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 8, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: Colors.green.shade100,
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: const Text(
                          //     '会员权益已开通',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: Colors.green,
                          //     ),
                          //   ),
                          // ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 2),
                            margin: const EdgeInsets.only(top: 5),
                            child: const Text(
                              '关注: 100   粉丝: 100',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 新鲜人提示
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '新鲜人',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.info_outline, size: 16),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '还差1200成长值获2次冰箱开门',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFunctionItem(Icons.apartment, '精准定尺寸'),
                        _buildFunctionItem(Icons.receipt_long, '纪念墙壁纸'),
                        _buildFunctionItem(Icons.camera_alt_outlined, '免费拍摄装修'),
                        _buildFunctionItem(Icons.calendar_today, '生日专享'),
                        _buildFunctionItem(Icons.more_horiz, '更多'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 功能图标区域

            // 活动卡片区域
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GFCard(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.all(10),
                      content: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.local_shipping,
                                color: Colors.blue),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '海马体重球',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '加入社群',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GFCard(
                      margin: const EdgeInsets.only(left: 5),
                      padding: const EdgeInsets.all(10),
                      content: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                const Icon(Icons.camera, color: Colors.purple),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '时光故事机',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '留住年轮',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
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
      //   bottomNavigationBar: CustomBottomNavigation(
      //   currentIndex: 3, // 当前是首页
      // ),
    );
  }

  Widget _buildFunctionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
