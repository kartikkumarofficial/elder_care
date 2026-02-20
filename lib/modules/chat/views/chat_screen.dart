import 'package:elder_care/app/utils/phone_call.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../../auth/controllers/auth_controller.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String partnerId;
  final String partnerName;
  final String? partnerImage;
  ChatScreen({Key? key, required this.chatId, required this.partnerId, required this.partnerName, this.partnerImage}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver{
  late final ChatController controller;


  final AuthController authController = Get.find<AuthController>();

  final TextEditingController textController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);


    controller = Get.put(ChatController(), tag: widget.chatId);

    controller.initChat(
      chatId: widget.chatId,
      partnerId: widget.partnerId,
      partnerName: widget.partnerName,
      partnerImage: widget.partnerImage,
    );
  }
  @override
  void dispose() {
    Get.delete<ChatController>(tag: widget.chatId);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;

    if (bottomInset > 0) {
      // Keyboard opened
      _scrollToBottom();
    }
  }

  bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

// keyboard opens -> padding and scroll to bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = authController.user.value;

    return Scaffold(
      extendBody: true,


      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Obx(() => Row(
          children: [
            SizedBox(width: Get.width * 0.05),
            CircleAvatar(
              radius: 20,
              // backgroundImage: controller.partnerImage.value != null
              //     ? NetworkImage(controller.partnerImage.value!)
              //     : null,
              backgroundImage: controller.partnerImage.value != null &&
                  controller.partnerImage.value!.isNotEmpty
                  ? NetworkImage(controller.partnerImage.value!)
                  : null,
              backgroundColor: Colors.teal.shade100,
              child: controller.partnerImage.value == null
                  ? const Icon(Icons.person, color: Colors.teal)
                  : null,
            ),
            SizedBox(width: Get.width * 0.05),
            Text(
              controller.partnerName.value,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        )),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {
            makePhoneCall("");
          }),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),

      // ✅ BODY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF4F2), Color(0xFFFDFBF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          _scrollToBottom();

          return Stack(
            children: [
              _chatBackground(),
              /// CHAT LIST
              ListView.builder(
                controller: scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                padding:  EdgeInsets.fromLTRB(Get.width*0.002, 16, Get.width*0.002, Get.height*0.2),
                itemCount: controller.messages.length,
                itemBuilder: (_, i) {
                  final msg = controller.messages[i];
                  final isMe = msg.senderId == me!.id;

                  return ChatBubble(
                    message: msg.content,
                    isMe: isMe,
                    time: msg.createdAt,
                    isSeen: isMe ? msg.isSeen : false,
                  );
                },
              ),

              /// FLOATING INPUT BAR
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _inputBar(),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// INPUT BAR
  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Type a message…",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF7AB7A7),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () {
                      final text = textController.text.trim();
                      if (text.isEmpty) return;

                      controller.sendMessage(text);
                      textController.clear();
                      _scrollToBottom();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _chatBackground() {
  return Positioned.fill(
    child: Opacity(
      opacity: 0.3,
      child: Image.asset(
        'assets/images/chat_bgg.png',
        fit: BoxFit.cover,
      ),
    ),
  );
}
