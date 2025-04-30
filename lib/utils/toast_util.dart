import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

class ToastUtil {
  static void showSuccess(String message) {
    _showToast(message, Icons.check_circle, Colors.green, 'success');
  }

  static void showDanger(String message) {
    _showToast(message, Icons.error, Colors.red, 'danger');
  }

  static void showWarning(String message) {
    _showToast(message, Icons.warning, Colors.orange, 'warning');
  }

  static void showPrimary(String message) {
    _showToast(message, Icons.info, Colors.blue, 'primary');
  }

  static void _showToast(
      String message, IconData icon, Color iconColor, String type) {
    BotToast.showCustomText(
      toastBuilder: (cancelFunc) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 2),
      align: const Alignment(0, -0.7),
      onlyOne: true,
      crossPage: true,
      clickClose: true,
      backgroundColor: Colors.transparent,
      animationDuration: const Duration(milliseconds: 200),
    );
  }
}
