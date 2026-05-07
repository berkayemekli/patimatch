import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_strings.dart';
import 'data/app_providers.dart';
import 'data/chat_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.chatId,
    required this.title,
  });

  final String chatId;
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  String _status = '';
  int _lastMessageCount = 0;
  DateTime? _lastReadWriteAt;
  DateTime? _lastSentAt;
  String _lastSentText = '';
  final ChatRepository _chatRepository = AppProviders.chatRepository;

  Future<void> _blockOtherUserFromChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _status = AppStrings.userNotFound);
      return;
    }
    try {
      final chatSnap = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .get();
      final chatData = chatSnap.data() ?? <String, dynamic>{};
      final participantOwnerIds =
          (chatData['participantOwnerIds'] as List<dynamic>? ?? <dynamic>[])
              .whereType<String>()
              .toList();
      final otherUserId = participantOwnerIds.firstWhere(
        (id) => id != user.uid,
        orElse: () => '',
      );
      if (otherUserId.isEmpty) {
        setState(() => _status = 'Engellenecek kullanici bulunamadi.');
        return;
      }

      await _chatRepository.blockUser(
        userId: user.uid,
        blockedUserId: otherUserId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanici engellendi.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _status = 'Engelleme basarisiz: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markChatRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    if (_lastReadWriteAt != null &&
        now.difference(_lastReadWriteAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastReadWriteAt = now;
    await _chatRepository.markChatRead(
      chatId: widget.chatId,
      userId: user.uid,
    );
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      return;
    }
    _scrollController.jumpTo(target);
  }

  Future<void> _sendMessage() async {
    if (_sending) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _status = AppStrings.userNotFound);
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    if (_lastSentAt != null &&
        now.difference(_lastSentAt!) < const Duration(milliseconds: 700)) {
      setState(() => _status = AppStrings.chatTooFast);
      return;
    }
    if (text == _lastSentText &&
        _lastSentAt != null &&
        now.difference(_lastSentAt!) < const Duration(seconds: 20)) {
      setState(() => _status = AppStrings.chatDuplicate);
      return;
    }

    setState(() {
      _sending = true;
      _status = '';
    });

    try {
      await _chatRepository.sendMessage(
        chatId: widget.chatId,
        senderUserId: user.uid,
        text: text,
      );

      _messageController.clear();
      _lastSentAt = DateTime.now();
      _lastSentText = text;
      await _markChatRead();
    } catch (e) {
      setState(() => _status = '${AppStrings.chatSendFailedPrefix}$e');
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _reportMessage({
    required String messageId,
    required String senderUserId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _chatRepository.reportMessage(
      reporterUserId: user.uid,
      reportedUserId: senderUserId,
      chatId: widget.chatId,
      messageId: messageId,
      reportedMessageText: text,
    );
  }

  Future<void> _onMessageLongPress({
    required String messageId,
    required String senderUserId,
    required String text,
    required bool isMine,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy),
                title: Text(AppStrings.chatCopy),
                onTap: () => Navigator.pop(context, 'copy'),
              ),
              ListTile(
                leading: Icon(Icons.flag),
                title: Text(AppStrings.chatReportMessage),
                onTap: () => Navigator.pop(context, 'report'),
              ),
              if (isMine)
                ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text(AppStrings.chatDeleteMessage),
                  onTap: () => Navigator.pop(context, 'delete'),
                ),
            ],
          ),
        );
      },
    );

    if (action == null) return;
    try {
      if (action == 'copy') {
        await Clipboard.setData(ClipboardData(text: text));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.chatCopied)),
        );
        return;
      }
      if (action == 'report') {
        await _reportMessage(
          messageId: messageId,
          senderUserId: senderUserId,
          text: text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.chatReported)),
        );
        return;
      }
      if (action == 'delete' && isMine) {
        await _chatRepository.softDeleteMessage(
          chatId: widget.chatId,
          messageId: messageId,
          senderUserId: senderUserId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.chatDeleted)),
        );
      }
    } catch (e) {
      setState(() => _status = '${AppStrings.actionFailedPrefix}$e');
    }
  }

  String _formatTime(dynamic ts) {
    if (ts is! Timestamp) return '';
    final dt = ts.toDate();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final myUserId = user?.uid ?? '';
    final messagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'block') {
                await _blockOtherUserFromChat();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'block',
                child: Text('Kullaniciyi Engelle'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text(AppStrings.chatNoMessages));
                }
                if (docs.length != _lastMessageCount) {
                  _lastMessageCount = docs.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom(animated: true);
                    _markChatRead();
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final sender = data['senderUserId'] as String? ?? '';
                    final text = data['text'] as String? ?? '';
                    final messageId = data['messageId'] as String? ?? docs[index].id;
                    final createdAt = data['createdAt'];
                    final isDeleted = data['isDeleted'] == true;
                    final isMine = sender == myUserId;

                    return Align(
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: InkWell(
                        onLongPress: () => _onMessageLongPress(
                          messageId: messageId,
                          senderUserId: sender,
                          text: text,
                          isMine: isMine,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isMine ? const Color(0xFFD1F5D3) : const Color(0xFFEAEAEA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                text,
                                style: TextStyle(
                                  fontStyle:
                                      isDeleted ? FontStyle.italic : FontStyle.normal,
                                  color: isDeleted ? Colors.grey.shade700 : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_status),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: AppStrings.chatTypeHint,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sending ? null : _sendMessage,
                    child: const Text('Gonder'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
