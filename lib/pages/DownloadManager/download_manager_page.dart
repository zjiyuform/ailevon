// pages/download_manager_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DownloadManagerPage extends StatefulWidget {
  const DownloadManagerPage({super.key});

  @override
  State<DownloadManagerPage> createState() => _DownloadManagerPageState();
}

class _DownloadManagerPageState extends State<DownloadManagerPage> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  // MethodChannel 用于调用原生 MediaStore
  static const platform = MethodChannel('com.example.download/media');

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  /// 获取下载文件存放的目录（私有目录）
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadDir = Directory('${externalDir.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir;
  }

  /// 加载所有文件
  Future<void> _loadDownloadedFiles() async {
    setState(() => _isLoading = true);
    try {
      final dir = await _getDownloadDirectory();
      final List<FileSystemEntity> entities = await dir.list().toList();
      entities.sort((a, b) {
        final aStat = File(a.path).statSync();
        final bStat = File(b.path).statSync();
        return bStat.modified.compareTo(aStat.modified);
      });
      setState(() {
        _files = entities.whereType<File>().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载失败: $e')));
      }
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 打开文件
  Future<void> _viewFile(File file) async {
    String? mimeType;
    final fileName = file.path.split('/').last;
    if (fileName.endsWith('.epub')) {
      mimeType = 'application/epub+zip';
    } else if (fileName.endsWith('.txt')) {
      mimeType = 'text/plain';
    }
    await OpenFile.open(file.path, type: mimeType);
  }

  /// 删除文件
  Future<void> _deleteFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除文件'),
        content: Text('确定要删除 ${file.path.split('/').last} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await file.delete();
        await _loadDownloadedFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '已删除${file.path.split('/').last}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  /// 移动单个文件到公共 Download 目录
  Future<void> _moveFileToPublicDownloads(File file) async {
    final fileName = file.path.split('/').last;
    try {
      final result = await platform.invokeMethod('moveToDownloads', {
        'sourcePath': file.path,
        'fileName': fileName,
      });
      if (result == true) {
        await _loadDownloadedFiles(); // 刷新列表（原文件已删除）
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已移动: $fileName 到公共 Downloads')),
          );
        }
      } else {
        throw Exception('移动失败');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('移动失败: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('移动出错: $e')));
      }
    }
  }

  /// 移动所有文件到公共 Download 目录（带进度提示）
  Future<void> _moveAllToPublicDownloads() async {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有文件可移动')));
      return;
    }

    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('移动所有文件'),
        content: Text(
          '将 ${_files.length} 个文件移动到系统 Downloads 目录？\n(此私有目录中的文件将被删除)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认移动', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // 显示进度对话框
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    int successCount = 0;
    int failCount = 0;

    for (final entity in _files) {
      final file = entity as File;
      try {
        final result = await platform.invokeMethod('moveToDownloads', {
          'sourcePath': file.path,
          'fileName': file.path.split('/').last,
        });
        if (result == true) {
          successCount++;
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      }
    }

    // 关闭进度对话框
    if (mounted) Navigator.pop(context);

    // 刷新列表
    await _loadDownloadedFiles();

    // 显示结果
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('移动完成：成功 $successCount，失败 $failCount')),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的下载'),
        actions: [
          // 说明按扭
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // 说明文本
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: true, // 允许点击外部关闭
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('提示'),
                      content: const Text(
                        '关于移动到 Download 公共目录：\n\n'
                        '应用私有目录中的文件默认不能被其他应用直接访问，因此部分阅读器的文件搜索功能可能无法找到这些下载文件。'
                        '将文件移动到公共的 Download 目录后，文件会被系统媒体库索引，阅读器等应用即可正常搜索和打开。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            '我知道了',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          // 移动所有按钮
          IconButton(
            icon: const Icon(Icons.drive_file_move),
            onPressed: _moveAllToPublicDownloads,
            tooltip: '全部移动到公共Downloads',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDownloadedFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
          ? const Center(child: Text('暂无下载文件'))
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index] as File;
                final stat = file.statSync();
                final fileName = file.path.split('/').last;
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(fileName),
                  subtitle: Text(
                    '${_formatFileSize(stat.size)} · ${_formatDateTime(stat.modified)}',
                  ),
                  onTap: () => _viewFile(file),
                  onLongPress: () => _deleteFile(file),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') _deleteFile(file);
                      if (value == 'open') OpenFile.open(file.path);
                      if (value == 'move') _moveFileToPublicDownloads(file);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new),
                            SizedBox(width: 8),
                            Text('打开'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'move',
                        child: Row(
                          children: [
                            Icon(Icons.drive_file_move),
                            SizedBox(width: 8),
                            Text('移动到公共Downloads'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
