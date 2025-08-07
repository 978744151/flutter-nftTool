import 'package:flutter/material.dart';

import '../../utils/http_client.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import '../../api/nft.dart';

import '../../widgets/purchase_options_sheet.dart'; // Add this import
import 'nft_sliver_app_bar.dart';

class NftInfo {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String quantity;
  final String soldQty;
  final Map<String, dynamic>? owner; // 直接使用 Map
  final List<dynamic> editions;
  final int? status;
  final String? blockchain_id;
  NftInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.editions,
    required this.soldQty,
    this.status,
    this.owner,
    this.blockchain_id = '',
  });
  factory NftInfo.fromJson(Map<String, dynamic> json) {
    return NftInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      owner: json['owner'] as Map<String, dynamic>?,
      editions: json['editions'] ?? [],
      soldQty: json['soldQty']?.toString() ?? '',
      status: json['status'] as int?,
      blockchain_id: json['blockchain_id']?.toString() ?? '',
    );
  }
}

class NftEditionDetail extends StatefulWidget {
  final String id; // 添加 id 参数
  final String nftId;

  const NftEditionDetail({
    Key? key,
    required this.id,
    required this.nftId,
  });

  @override
  State<NftEditionDetail> createState() => _NftEditionDetailState();
}

class _NftEditionDetailState extends State<NftEditionDetail>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  late NftInfo nftInfo;
  late NftInfo nftDetail;
  List<Map<dynamic, dynamic>> allEditions = [];
  List<Map<dynamic, dynamic>> filteredEditions = [];
  int editionsCount = 0;
  bool _showTitle = false; // 添加标题显示控制
  double _scrollProgress = 0.0; // 添加滚动进度变量
  late AnimationController _imageAnimationController;
  late Animation<double> _imageScaleAnimation;
  late AnimationController _detailsAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _tapAnimationController;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 初始化动画控制器
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 立即初始化动画
    _imageScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _imageAnimationController, curve: Curves.easeOutBack));

    _detailsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _detailsAnimationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _detailsAnimationController, curve: Curves.easeOut));

    _tapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );

    // 初始化 nftInfo
    nftInfo = NftInfo(
        id: '',
        name: '',
        imageUrl: '',
        price: '',
        quantity: '',
        editions: [],
        soldQty: '');
    // 初始化 nftDetail
    nftDetail = NftInfo(
        id: '',
        name: '',
        imageUrl: '',
        price: '',
        quantity: '',
        blockchain_id: '',
        editions: [],
        soldQty: '');
    // 获取数据并启动动画
    fetchData();
    fetchDetail();
    fetchConsignmentsList();

    // 延迟启动动画，确保有足够时间初始化
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _imageAnimationController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _detailsAnimationController.forward();
        });
      }
    });
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    try {
      print(widget);
      final nftId = widget.nftId;
      final response = await HttpClient.get('/nfts/$nftId');

      if (!mounted) return;
      if (response['success'] != false) {
        final data = response['data'];
        // 确保数据格式正确
        if (data != null && data is Map<String, dynamic>) {
          setState(() {
            nftInfo = NftInfo.fromJson(data);
            isLoading = false;
          });
          // 验证状态更新
        } else {
          print('Invalid data format: $data');
        }
      }
    } catch (e) {
      print(e);
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

  Future<void> fetchDetail() async {
    final response = await HttpClient.get('/nfts/editions/detail',
        params: {'id': widget.nftId, 'editionId': widget.id});
    setState(() {
      nftDetail = NftInfo.fromJson(response['data']);
    });
  }

  Future<void> fetchConsignmentsList() async {
    if (!mounted) return;
    try {
      final ids = widget.id;
      final response = await HttpClient.get(NftConfigApi.getNFTConsignments);

      // if (!mounted) return;
      // if (response['success'] != false) {
      //   final data = response['data'];
      //   // 确保数据格式正确
      //   if (data != null && data is Map<String, dynamic>) {
      //     setState(() {});
      //     // 验证状态更新
      //   } else {
      //     print('Invalid data format: $data');
      //   }
      // }
    } catch (e) {
      print(e);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      // 添加错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新失败：${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imageAnimationController.dispose();
    _detailsAnimationController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  void _showPurchaseOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the sheet to take up more screen height
      shape: const RoundedRectangleBorder(
        // Add rounded corners to the top
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return PurchaseOptionsSheet(
            imageUrl: nftInfo.imageUrl,
            price: nftInfo.price,
            name: nftInfo.name,
            id: nftInfo.id // Assuming quantity represents stock
            // Pass other necessary data if needed
            );
      },
    );
  }

  void _showPasswordDialog(
      BuildContext context, NftInfo nftInfo, NftInfo nftDetail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // 使用根导航器，确保覆盖所有UI元素
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 20,
      clipBehavior: Clip.antiAliasWithSaveLayer, // 添加裁剪行为
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return SizedBox(
          // heightFactor: 0.4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 添加一个小横条作为拖动指示器
                // Center(
                //   child: Container(
                //     width: 40,
                //     height: 5,
                //     margin: const EdgeInsets.only(bottom: 8),
                //     decoration: BoxDecoration(
                //       color: Colors.grey[300],
                //       borderRadius: BorderRadius.circular(2.5),
                //     ),
                //   ),
                // ),
                Container(
                    // child: _showConsignDialog(context, nftInfo, nftDetail),
                    ),
                const SizedBox(height: 16),
                // 资格券列表
              ],
            ),
          ),
        );
      },
    );
  }

// 密码输入对话框
  Widget _buildPasswordInputDialog() {
    return Container(
      // padding: const EdgeInsets.all(24),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1),
      //       blurRadius: 20,
      //       offset: const Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          const Text(
            '请输入支付密码',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '为了您的账户安全，请输入6位支付密码',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // 密码输入框
          _buildPasswordInput(),

          const SizedBox(height: 32),

          // 数字键盘
          _buildNumberKeyboard(),

          const SizedBox(height: 16),

          // 忘记密码
          // TextButton(
          //   onPressed: () {
          //     // 处理忘记密码
          //   },
          //   child: const Text(
          //     '忘记密码？',
          //     style: TextStyle(
          //       color: Colors.blue,
          //       fontSize: 14,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

// 密码输入框组件
  Widget _buildPasswordInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        bool isFilled = _password.length > index;
        bool isCurrent = _password.length == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent
                  ? Colors.blue
                  : isFilled
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
              width: isCurrent ? 2 : 1,
            ),
            color: isFilled ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isFilled
                  ? Container(
                      key: ValueKey('filled_$index'),
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    )
                  : isCurrent
                      ? Container(
                          key: ValueKey('cursor_$index'),
                          width: 2,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),
          ),
        );
      }),
    );
  }

// 数字键盘
  Widget _buildNumberKeyboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 第一行: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3]
                .map((number) => _buildKeyboardButton(number.toString()))
                .toList(),
          ),
          const SizedBox(height: 16),
          // 第二行: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [4, 5, 6]
                .map((number) => _buildKeyboardButton(number.toString()))
                .toList(),
          ),
          const SizedBox(height: 16),
          // 第三行: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [7, 8, 9]
                .map((number) => _buildKeyboardButton(number.toString()))
                .toList(),
          ),
          const SizedBox(height: 16),
          // 第四行: 空, 0, 删除
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60), // 占位
              _buildKeyboardButton('0'),
              _buildKeyboardButton('delete', isDelete: true),
            ],
          ),
        ],
      ),
    );
  }

// 键盘按钮
  Widget _buildKeyboardButton(String value, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () {
        if (isDelete) {
          _deletePassword();
        } else {
          _addPassword(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace_outlined,
                  color: Colors.grey,
                  size: 24,
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }

// 在类的顶部添加密码状态变量
  String _password = '';

// 添加密码
  void _addPassword(String digit) {
    if (_password.length < 6) {
      setState(() {
        _password += digit;
      });

      // 如果密码长度达到6位，自动验证
      if (_password.length == 6) {
        _verifyPassword();
      }
    }
  }

// 删除密码
  void _deletePassword() {
    if (_password.isNotEmpty) {
      setState(() {
        _password = _password.substring(0, _password.length - 1);
      });
    }
  }

// 验证密码
  void _verifyPassword() {
    // 这里添加密码验证逻辑
    print('输入的密码: $_password');

    // 模拟验证过程
    Future.delayed(const Duration(milliseconds: 500), () {
      // 验证成功后的处理
      Navigator.of(context).pop();
      // 继续支付流程
    });
  }

  void _showNftDetailDialog(BuildContext context, NftInfo nftInfo) {
    // Accept BuildContext
    // var context; // Remove this line
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // 使用根导航器，确保覆盖所有UI元素
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 20,
      clipBehavior: Clip.antiAliasWithSaveLayer, // 添加裁剪行为
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        // 获取editions数据并筛选status为2或3的项目
        return SizedBox(
          // heightFactor: 0.4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 添加一个小横条作为拖动指示器
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                Container(
                  child: PurchaseOptionsSheet(
                      imageUrl: nftInfo.imageUrl, // 替换成实际的图片 URL
                      price: nftInfo.price, // 替换成实际的价格
                      name: nftInfo
                          .name, // 替换成实际的库存uming quantity represents stock
                      id: nftInfo.id
                      // Pass other necessary data if needed
                      ),
                ),
                const SizedBox(height: 16),
                // 资格券列表
              ],
            ),
          ),
        );
      },
    ).then((result) {
      print('购买结果: $result');
      // 当购买成功时，result为true，调用fetchData刷新数据
      if (result == true) {
        // 需要在这里调用fetchData，但是这个方法在类外部，需要传递引用
        // 或者将这个方法移到类内部
        fetchData(); // 等待数据加载完成
      }
    });
  }

  void _showConsignDialog(
      BuildContext context, NftInfo nftInfo, NftInfo nftDetail) {
    double price = 0.0;
    double fee = 0.0;
    double receive = 0.0;
    final TextEditingController priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void onPriceChanged(String value) {
              price = double.tryParse(value) ?? 0.0;
              fee = double.parse((price * 0.06).toStringAsFixed(2));
              receive = double.parse((price - fee).toStringAsFixed(2));
              setState(() {});
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部标题栏
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '藏品寄售',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 24,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 内容区域
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NFT信息卡片
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  nftDetail.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nftDetail.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '拥有数量 ${nftDetail.quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 寄售价格输入
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '寄售价格',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '市场参考价：¥2666 - ¥43843',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: const Text(
                                      '¥',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: priceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '5555',
                                        hintStyle: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onChanged: onPriceChanged,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: Text(
                                      'CNY',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 费用明细
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '费用明细',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                      '寄售价格', '¥${price.toStringAsFixed(2)}'),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('平台服务费(6%)',
                                      '-¥${fee.toStringAsFixed(2)}'),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    '预计到账',
                                    '¥${receive.toStringAsFixed(2)}',
                                    // isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 寄售须知
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '寄售须知',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '1.商品未经购买前，可取消上架，取消挂单后三分钟禁止上单，一经购买，无法取消上架。\n\n2.您将获得除合服务费(6%)之外的所有售收入。\n\n3.寄售收入在扣除合服务费后，将自动转入第三方钱包余额。',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 确认按钮
                        Container(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: price > 0
                                ? () async {
                                    // TODO: 提交寄售请求
                                    Navigator.pop(context);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: const Text(
                              '确认寄售',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // 底部安全距离
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// 辅助方法：构建明细行
  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final scrollProgress = notification.metrics.pixels / 200.0;
          setState(() {
            _scrollProgress = scrollProgress.clamp(0.0, 1.0);
            _showTitle = _scrollProgress > 0.5;
          });
        }
        return false;
      },
      child: Hero(
        tag: "nft-detail-${widget.id}",
        child: Material(
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  NftSliverAppBarWithImage(
                    title: nftInfo.name,
                    imageUrl: nftInfo.imageUrl,
                    isLoading: isLoading,
                    expandedHeight: 340,
                    scrollProgress: _scrollProgress,
                    showTitle: _showTitle,
                  ),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        color: const Color(0xFFFFFFFF),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nftInfo.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '限量版',
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 添加小波浪动画
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Text(
                                '¥ ${nftInfo.price}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 详情模块

                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '总量:  ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${nftInfo.soldQty} / ${nftInfo.quantity} 份',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '当前流通:  ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Text(
                                        '0份',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              // decoration: BoxDecoration(
                              //   color: Colors.blue[50],
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    nftDetail.owner != null &&
                                            nftDetail.owner!['name'] != null
                                        ? '拥有者：' +
                                            nftDetail.owner!['name'].toString()
                                        : '拥有者',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NFT ID：' +
                                        (nftDetail.blockchain_id ?? '暂无'),
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                  ),

                                  // 可根据实际需求添加更多属性
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Stack(
                children: [
                  Container(),
                  // 底部立即购买按钮
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Container(
                      color: Colors.white.withOpacity(0.95),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          fixedSize: const Size.fromHeight(52),
                        ),
                        onPressed: () async {
                          // 根据NFT状态执行不同的操作
                          // 1:未寄售, 2:寄售中, 3:锁定中, 4:已售出, 5:已发布, 6:空投, 7:合成
                          if (_canPurchase(nftDetail.status)) {
                            // _showNftDetailDialog(context, nftInfo);
                          } else {
                            _showStatusMessage(nftDetail.status);
                          }
                          if (nftDetail.status == 1) {
                            _showConsignDialog(context, nftInfo, nftDetail);
                          }
                          if (nftDetail.status == 2)
                            final response = await HttpClient.post(
                                '/nfts/editions/cancel-consign',
                                body: {
                                  'id': widget.nftId,
                                  'editionId': widget.id
                                });
                        },
                        child: Text(
                          _getButtonText(nftDetail.status),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// NFT基础信息展示组件
class NftBaseInfoBox extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final int? status; // 1:已售出 2:寄售 3:寄售中 4:暂不支持寄售
  final Color? bgColor;
  final VoidCallback? onImageTap;
  final VoidCallback? onButtonTap;

  const NftBaseInfoBox({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.status,
    this.bgColor,
    this.onImageTap,
    this.onButtonTap,
  }) : super(key: key);

  String getStatusText(int? status) {
    switch (status) {
      case 1:
        return '已售出';
      case 2:
        return '寄售';
      case 3:
        return '寄售中';
      case 4:
        return '暂不支持寄售';
      default:
        return '未知状态';
    }
  }

  Color getStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 180,
                  height: 180,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '¥$price',
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              getStatusText(status),
              style: TextStyle(
                color: getStatusColor(status),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(status),
        ],
      ),
    );
  }

  Widget _buildActionButton(int? status) {
    switch (status) {
      case 1:
        return _buildDisabledButton('已售出');
      case 2:
        return _buildPrimaryButton('寄售');
      case 3:
        return _buildDisabledButton('寄售中');
      case 4:
        return _buildDisabledButton('暂不支持寄售');
      default:
        return _buildDisabledButton('未知状态');
    }
  }

  Widget _buildPrimaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onButtonTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDisabledButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Remove the old top-level function if it exists

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// 判断是否可以购买
bool _canPurchase(int? status) {
  switch (status) {
    case 1: // 未寄售
    case 5: // 已发布
      return true;
    case 3: // 锁定中
    case 4: // 已售出
    case 6: // 空投
    case 7: // 合成
    default:
      return false;
  }
}

// 获取按钮文本
String _getButtonText(int? status) {
  switch (status) {
    case 1:
      return '去寄售';
    case 2:
      return '取消寄售';
    case 3:
      return '锁定中';
    case 4:
      return '已售出';
    // case 5:
    //   return '立即购买';
    // case 6:
    //   return '空投获得';
    // case 7:
    //   return '合成获得';
    default:
      return '暂不可用';
  }
}

// 显示状态消息
void _showStatusMessage(int? status) {
  String message;
  switch (status) {
    case 3:
      message = '该NFT当前处于锁定状态，暂时无法购买';
      break;
    case 4:
      message = '该NFT已售出';
      break;
    case 6:
      message = '该NFT通过空投获得，无法购买';
      break;
    case 7:
      message = '该NFT通过合成获得，无法购买';
      break;
    default:
      message = '当前状态下无法进行此操作';
  }

  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Text(message),
  //     backgroundColor: Colors.orange,
  //   ),
  // );
}
