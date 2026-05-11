import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/receive_history_provider.dart';
import 'package:localsend_app/util/file_size_helper.dart';
import 'package:localsend_app/util/native/open_file.dart';
import 'package:localsend_app/util/native/open_folder.dart';
import 'package:localsend_app/widget/dialogs/file_info_dialog.dart';
import 'package:localsend_app/widget/dialogs/history_clear_dialog.dart';
import 'package:refena_flutter/refena_flutter.dart';

class HuaweiReceiveHistoryPage extends StatelessWidget {
  const HuaweiReceiveHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch(receiveHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.receiveHistoryPage.title),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final clear = await showDialog(context: context, builder: (_) => const HistoryClearDialog());
                if (clear == true) {
                  context.ref.redux(receiveHistoryProvider).dispatch(ClearReceiveHistoryAction());
                }
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 72, color: HuaweiColors.textTertiary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(t.receiveHistoryPage.empty, style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: entry.path != null
                        ? () async => openFile(context, entry.fileType, entry.path!)
                        : null,
                    onLongPress: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => FileInfoDialog(entry: entry),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: HuaweiColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getFileIcon(entry.fileType),
                              color: HuaweiColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.fileName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${entry.size.asReadableFileSize} · ${_formatTimestamp(entry.timestamp)}',
                                  style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (entry.path != null)
                            IconButton(
                              icon: const Icon(Icons.folder_open, size: 20),
                              color: HuaweiColors.textTertiary,
                              onPressed: () async => openFolder(folderPath: entry.path!),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getFileIcon(dynamic fileType) {
    final name = fileType.toString();
    if (name.contains('image')) return Icons.image_outlined;
    if (name.contains('video')) return Icons.videocam_outlined;
    if (name.contains('audio')) return Icons.audiotrack_outlined;
    if (name.contains('pdf')) return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
    return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
