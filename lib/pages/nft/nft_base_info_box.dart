import 'package:flutter/material.dart';

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
