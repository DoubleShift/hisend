import 'dart:async';

import 'package:common/model/file_status.dart';
import 'package:common/model/session_status.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/server/receive_session_state.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/progress_provider.dart';
import 'package:localsend_app/util/file_size_helper.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class HuaweiProgressPage extends StatefulWidget {
  final String sessionId;

  const HuaweiProgressPage({required this.sessionId, super.key});

  @override
  State<HuaweiProgressPage> createState() => _HuaweiProgressPageState();
}

class _HuaweiProgressPageState extends State<HuaweiProgressPage> with Refena {
  int _totalBytes = 0;
  List<dynamic> _files = [];
  Set<String> _selectedFiles = {};
  Timer? _finishTimer;
  int _finishCounter = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final receiveSession = ref.read(serverProvider)?.session;
        if (receiveSession != null) {
          _files = receiveSession.files.values.map((f) => f.file).toList();
          _selectedFiles = receiveSession.files.values.where((f) => f.status != FileStatus.skipped).map((f) => f.file.id).toSet();
        } else {
          final sendSession = ref.read(sendProvider)[widget.sessionId];
          if (sendSession != null) {
            _files = sendSession.files.values.map((f) => f.file).toList();
            _selectedFiles = sendSession.files.values.where((f) => f.status != FileStatus.skipped).map((f) => f.file.id).toSet();
          }
        }
        _totalBytes = _files.where((f) => _selectedFiles.contains(f.id)).fold(0, (prev, curr) => prev + curr.size);
      });
    });
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    super.dispose();
  }

  void _exit() {
    final receiveSession = ref.read(serverProvider)?.session;
    if (receiveSession != null) {
      ref.notifier(serverProvider).closeSession();
    } else {
      ref.notifier(sendProvider).closeSession(widget.sessionId);
    }
    context.popUntilRoot();
  }

  @override
  Widget build(BuildContext context) {
    final progressNotifier = ref.watch(progressProvider);
    final currBytes = _files.fold<int>(
      0,
      (prev, curr) {
        final progress = progressNotifier.getProgress(sessionId: widget.sessionId, fileId: curr.id);
        return prev + (progress * curr.size).round();
      },
    );

    final receiveSession = ref.watch(serverProvider.select((s) => s?.session));
    final sendSession = ref.watch(sendProvider)[widget.sessionId];
    final commonSessionState = receiveSession ?? sendSession;

    if (commonSessionState == null) {
      return const Scaffold(body: SizedBox());
    }

    final status = commonSessionState.status;
    final isReceiving = receiveSession != null;
    final progress = _totalBytes == 0 ? 0.0 : currBytes / _totalBytes;
    final finishedCount = _files.where((f) {
      final fileStatus = receiveSession?.files[f.id]?.status ?? sendSession?.files[f.id]?.status;
      return fileStatus == FileStatus.finished;
    }).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isReceiving ? t.progressPage.titleReceiving : t.progressPage.titleSending),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final fileStatus = receiveSession?.files[file.id]?.status ?? sendSession?.files[file.id]?.status ?? FileStatus.queue;
                  final fileName = receiveSession?.files[file.id]?.desiredName ?? file.fileName;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getStatusColor(fileStatus).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_getStatusIcon(fileStatus), color: _getStatusColor(fileStatus), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                if (fileStatus == FileStatus.sending)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progressNotifier.getProgress(sessionId: widget.sessionId, fileId: file.id),
                                      backgroundColor: HuaweiColors.dividerLight,
                                      valueColor: const AlwaysStoppedAnimation(HuaweiColors.primary),
                                    ),
                                  )
                                else
                                  Text(
                                    _fileStatusLabel(fileStatus),
                                    style: TextStyle(color: _getStatusColor(fileStatus), fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Text(file.size.asReadableFileSize, style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              status == SessionStatus.sending
                                  ? t.progressPage.total.title.sending(time: '-')
                                  : t.general.finished,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$finishedCount/${_selectedFiles.length}',
                              style: TextStyle(color: HuaweiColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: HuaweiColors.dividerLight,
                            valueColor: const AlwaysStoppedAnimation(HuaweiColors.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currBytes.asReadableFileSize} / ${_totalBytes.asReadableFileSize}',
                              style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _exit,
                            child: Text(status == SessionStatus.sending ? t.general.cancel : t.general.done),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(FileStatus status) {
    return switch (status) {
      FileStatus.finished => HuaweiColors.success,
      FileStatus.failed => HuaweiColors.error,
      FileStatus.sending => HuaweiColors.primary,
      FileStatus.skipped => Colors.grey,
      _ => HuaweiColors.textTertiary,
    };
  }

  IconData _getStatusIcon(FileStatus status) {
    return switch (status) {
      FileStatus.finished => Icons.check_circle_outline,
      FileStatus.failed => Icons.error_outline,
      FileStatus.sending => Icons.sync,
      FileStatus.skipped => Icons.skip_next,
      _ => Icons.schedule,
    };
  }

  String _fileStatusLabel(FileStatus status) {
    return switch (status) {
      FileStatus.queue => t.general.queue,
      FileStatus.skipped => t.general.skipped,
      FileStatus.sending => '',
      FileStatus.failed => t.general.error,
      FileStatus.finished => t.general.done,
    };
  }
}
