import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:getwidget/getwidget.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
      // 设置状态栏颜色为页面背景颜色
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.blue, // 状态栏背景色
          statusBarIconBrightness: Brightness.light, // 图标颜色（亮色）
        ),
      );
    }

    return Scaffold(
      // backgroundColor: Colors.white, // 修改为白色背景
      body: SafeArea(
        top: false, // 添加这行，让 SafeArea 不影响顶部

        child: Column(
          children: [
            // 顶部信息区域
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12, // 添加状态栏高度
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
                    Colors.white, // 渐变结束色改为白色
                  ],
                ),
              ),
              child: Column(
                children: [
                  // 顶部用户信息
                  Row(
                    children: [
                      // 用户头像
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://api.dicebear.com/9.x/avataaars/svg?seed=Felix',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 用户名和等级
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'lvg轩2',
                                  style: TextStyle(
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
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.verified_user,
                                          size: 12, color: Colors.blue[700]),
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
                            const Row(
                              children: [
                                _StatItem(count: '1', label: '关注'),
                                SizedBox(width: 16),
                                _StatItem(count: '0', label: '粉丝'),
                                SizedBox(width: 16),
                                // _StatItem(count: '1', label: '特权卡'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 右侧图标
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.headset_mic_outlined),
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
                      _buildMainFunction(Icons.access_time, '足迹'),
                      _buildMainFunction(Icons.star_border, '收藏'),
                      _buildMainFunction(Icons.send_outlined, '关注'),
                      _buildMainFunction(Icons.description_outlined, '订单'),
                      _buildMainFunction(Icons.shopping_cart_outlined, '消息',
                          hasNotification: true),
                    ],
                  ),
                ],
              ),
            ),

            // 二级功能区
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(),
                  border: Border(
                      top: BorderSide(
                        color: Colors.grey[100]!,
                        width: 1.0, // 边框宽度
                        style: BorderStyle.solid, // 边框样式
                      ),
                      bottom: BorderSide(
                        color: Colors.grey[100]!,
                        width: 1.0, // 边框宽度
                        style: BorderStyle.solid, // 边框样式
                      ))),
              // color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSecondaryFunction(
                        icon: Icons.local_gas_station,
                        iconColor: Colors.blue,
                        bgColor: Colors.blue[50]!,
                        label: '优惠券',
                      ),
                      _buildSecondaryFunction(
                        icon: Icons.card_giftcard,
                        iconColor: Colors.orange,
                        bgColor: Colors.orange[50]!,
                        label: '加油礼包',
                      ),
                      _buildSecondaryFunction(
                        icon: Icons.monetization_on,
                        iconColor: Colors.amber,
                        bgColor: Colors.amber[50]!,
                        label: '签到',
                        hasTag: true,
                      ),
                      _buildSecondaryFunction(
                        icon: Icons.directions_car,
                        iconColor: Colors.red,
                        bgColor: Colors.red[50]!,
                        label: '积分兑换',
                      ),
                      _buildSecondaryFunction(
                        icon: Icons.card_membership,
                        iconColor: Colors.blue,
                        bgColor: Colors.blue[50]!,
                        label: '钱包',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 活动广告条
            Container(
              // margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '每日专属好礼',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '领取200元车币',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '立即领取',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // 车主服务区
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '车主服务',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '南京',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: Colors.grey[600], size: 16),
                      Text(
                        '今日不推行',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 车主礼包卡片
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.card_giftcard,
                              color: Colors.orange[700]),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '200元车主大礼包',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '洗车优惠券等福利',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              Text(
                                '加油优惠',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 底部功能区
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomFunction(Icons.local_gas_station, '加油站油'),
                      _buildBottomFunction(Icons.car_repair, '去洗车'),
                      _buildBottomFunction(Icons.directions_car, '车主查询'),
                      _buildBottomFunction(Icons.card_giftcard, '车主会员'),
                      _buildBottomFunction(Icons.grid_view, '全部'),
                    ],
                  ),
                ],
              ),
            ),

            // 分割线
            // Container(
            //   margin: const EdgeInsets.symmetric(vertical: 8),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(width: 60, height: 1, color: Colors.grey[300]),
            //       const SizedBox(width: 8),
            //       Text('用车精选',
            //           style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            //       const SizedBox(width: 8),
            //       Container(width: 60, height: 1, color: Colors.grey[300]),
            //     ],
            //   ),
            // ),
          ],
        ),
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
