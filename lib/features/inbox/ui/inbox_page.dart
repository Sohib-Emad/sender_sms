import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/core/utils/extensions.dart';

class InboxPage extends StatefulWidget {
  final bool isTab;
  const InboxPage({super.key, this.isTab = false});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with WidgetsBindingObserver {
  final SmsService _smsService = sl<SmsService>();
  List<Map<String, dynamic>> _allMessages = [];
  List<Map<String, dynamic>> _filteredMessages = [];
  bool _isLoading = false;
  bool _hasPermission = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndLoad();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndLoad();
    }
  }

  Future<void> _checkPermissionAndLoad() async {
    final status = await Permission.sms.status;
    final isDefault = await _smsService.isDefaultSmsApp();
    
    if (status.isGranted || isDefault) {
      setState(() {
        _hasPermission = true;
      });
      _loadMessages();
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.sms.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _loadMessages();
    } else {
      // Prompt default SMS app settings
      await _smsService.requestDefaultSmsApp();
    }
  }

  Future<void> _loadMessages() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _smsService.getInboxMessages();
      setState(() {
        _allMessages = messages;
        _filterMessages(_searchQuery);
      });
    } catch (_) {
      if (mounted) context.showSnack('حدث خطأ أثناء تحميل الرسائل', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterMessages(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _filteredMessages = List.from(_allMessages);
    } else {
      final q = query.toLowerCase();
      _filteredMessages = _allMessages.where((msg) {
        final sender = (msg['sender'] as String).toLowerCase();
        final body = (msg['body'] as String).toLowerCase();
        return sender.contains(q) || body.contains(q);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل الواردة'),
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          if (_hasPermission)
            IconButton(
              icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded),
              onPressed: _loadMessages,
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return _buildPermissionDeniedState();
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadMessages,
            child: _buildMessagesList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDeniedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'صلاحية الرسائل مطلوبة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            const Text(
              'لرؤية الرسائل الواردة، يحتاج التطبيق إلى صلاحية قراءة SMS أو تعيينه كتطبيق افتراضي للرسائل.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.security_rounded),
                label: const Text('تفعيل الصلاحية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _filterMessages(val)),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'البحث في الرسائل الواردة...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filterMessages(''));
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildMessagesList() {
    if (_isLoading && _allMessages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredMessages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final msg = _filteredMessages[index];
        final sender = msg['sender'] as String;
        final body = msg['body'] as String;
        final timestamp = msg['timestamp'] as int;
        
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final timeStr = dateTime.relativeTime;

        return _buildMessageCard(sender, body, timeStr, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView( // wrap in ListView to support refresh indicator pull down
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'لا توجد رسائل واردة' : 'لا توجد نتائج بحث مطابقة',
                style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              if (_searchQuery.isEmpty)
                const Text(
                  'اسحب لأسفل لتحديث الرسائل الواردة',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textDirection: TextDirection.rtl,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(String sender, String body, String timeStr, int index) {
    final initial = sender.isNotEmpty ? (sender.startsWith('+') ? sender.substring(1, 2) : sender.substring(0, 1)) : 'S';
    
    // Choose a color theme for the avatar based on sender string
    final avatarColor = Colors.primaries[sender.hashCode % Colors.primaries.length];

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showMsgDetailDialog(sender, body, timeStr),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            sender,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: (index * 40).ms).slideY(begin: 0.1, duration: 350.ms, delay: (index * 40).ms);
  }

  void _showMsgDetailDialog(String sender, String body, String timeStr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                sender,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeStr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                ),
                child: Text(
                  body,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
