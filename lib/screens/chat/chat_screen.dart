import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/app_state.dart';
import '../../models/rental_item.dart';
import '../../models/rental_request.dart';
import '../../models/chat_model.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.args});

  final dynamic args;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _chatService = ChatService();
  
  ChatModel? _chatRoom;
  String _targetName = 'User';
  bool _isLoading = true;
  String? _initError;
  List<ChatMessage> _cachedMessages = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }
  
  Future<void> _initChat() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
       if (mounted) setState(() => _isLoading = false);
      return;
    }
    
    String listingId = '';
    String listingTitle = '';
    String borrowerId = '';
    String borrowerName = '';
    String ownerId = '';
    String ownerName = '';
    
    if (widget.args is RentalRequest) {
      final req = widget.args as RentalRequest;
      listingId = req.listingId;
      listingTitle = req.listingTitle;
      borrowerId = req.borrowerId;
      borrowerName = req.borrowerName;
      ownerId = req.ownerId;
      ownerName = req.ownerName;
      _targetName = currentUid == borrowerId ? ownerName : borrowerName;
    } else if (widget.args is RentalItem) {
      final item = widget.args as RentalItem;
      listingId = item.id;
      listingTitle = item.name;
      borrowerId = currentUid;
      borrowerName = 'Borrower'; 
      ownerId = item.ownerId;
      ownerName = item.ownerName;
      _targetName = ownerName;
    }
    
    final chatId = '${listingId}_${borrowerId}_$ownerId';
    
    _chatRoom = await _chatService.createOrGetChat(ChatModel(
      id: chatId,
      listingId: listingId,
      listingTitle: listingTitle,
      borrowerId: borrowerId,
      borrowerName: borrowerName,
      ownerId : ownerId,
      ownerName : ownerName,
    ));
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _sendMessage(SaamaGoStore store) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    _controller.clear();
    
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
       store.sendMessage(text);
       return;
    }
    
    if (_chatRoom != null) {
      final msg = ChatMessage(
        text: text,
        time: '',
        isMine: true,
        senderId: currentUid,
        senderName: '',
      );
      try {
        await _chatService.sendMessage(_chatRoom!.id, msg);
      } catch (e) {
        _controller.text = text;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message. Please check your connection.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStateScope.of(context);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isMock = currentUid == null;
    
    if (widget.args is RentalItem) {
      _targetName = (widget.args as RentalItem).ownerName;
    } else if (widget.args is RentalRequest) {
      final req = widget.args as RentalRequest;
      _targetName = currentUid == req.borrowerId ? req.ownerName : req.borrowerName;
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.elevatedCard,
              child: Icon(Icons.person, size: 20, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _targetName,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const Text(
                    'Typically replies within an hour',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _initError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.secondaryText),
                        const SizedBox(height: 12),
                        Text(
                          _initError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _initError = null;
                            });
                            _initChat();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: isMock 
                        ? _buildMockMessages(store.messages) 
                        : _buildStreamMessages(currentUid),
                    ),
                    _buildMessageInput(store),
                  ],
                ),
    );
  }

  Widget _buildMockMessages(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return const EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No messages yet',
        message: 'Start the conversation.',
      );
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _ChatBubble(message: message);
      },
    );
  }

  Widget _buildStreamMessages(String uid) {
    if (_chatRoom == null) return const SizedBox();

    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessagesStream(_chatRoom!.id, uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _cachedMessages = snapshot.data!;
        }

        if (snapshot.hasError && _cachedMessages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.secondaryText),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load messages',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData && _cachedMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = _cachedMessages;
        if (messages.isEmpty) {
          return const EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No messages yet',
            message: 'Start the conversation.',
          );
        }

        return Column(
          children: [
            if (snapshot.hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                color: AppColors.error.withValues(alpha: 0.15),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.error),
                    SizedBox(width: 6),
                    Text(
                      'Connection lost. Reconnecting...',
                      style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  if (!message.isMine && !message.isRead) {
                    _chatService.markMessageAsRead(_chatRoom!.id, message.id).catchError((_) {});
                  }
                  return _ChatBubble(message: message);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageInput(SaamaGoStore store) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.secondaryText),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: AppColors.input,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(store),
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.elevatedCard,
              child: Icon(Icons.person, size: 16, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMine ? AppColors.primaryBlue : AppColors.cardSurface,
                gradient: message.isMine ? AppColors.brandGradient : null,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isMine ? const Radius.circular(4) : null,
                  bottomLeft: !message.isMine ? const Radius.circular(4) : null,
                ),
                border: message.isMine ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMine ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: message.isMine ? Colors.white70 : AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMine) const SizedBox(width: 22), // space equivalent to avatar
        ],
      ),
    );
  }
}
