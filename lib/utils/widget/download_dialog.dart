import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String url;
  final String fileName;
  final Future<void> Function(void Function(int, int) progressCallback)
  onDownload;

  const DownloadProgressDialog({
    super.key,
    required this.url,
    required this.fileName,
    required this.onDownload,
  });

  @override
  State<DownloadProgressDialog> createState() => DownloadProgressDialogState();
}

class DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  String _status = '准备下载...';
  bool _isDownloading = true;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await widget.onDownload((received, total) {
        if (total != -1 && mounted) {
          setState(() {
            _progress = received / total;
            _status = '下载中 ${(_progress * 100).toStringAsFixed(1)}%';
          });
        }
      });
      if (mounted) {
        setState(() {
          _status = '下载完成！';
          _isDownloading = false;
        });
        // await Future.delayed(const Duration(seconds: 1));
        // if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '下载失败：$e';
          _isDownloading = false;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('下载进度'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: _progress,
            color: Colors.green,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(_status),
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
      ],
    );
  }
}
