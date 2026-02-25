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
  final double keyboardInset;
  ChatScreen({Key? key, required this.chatId, required this.partnerId, required this.partnerName, this.partnerImage, required this.keyboardInset}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController controller;


  final AuthController authController = Get.find<AuthController>();

  final TextEditingController textController = TextEditingController();

  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    controller = Get.put(ChatController(), tag: widget.chatId);

    controller.initChat(
      chatId: widget.chatId,
      partnerId: widget.partnerId,
      partnerName: widget.partnerName,
      partnerImage: widget.partnerImage,
    );

    /// Scroll after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    /// Listen for new messages
    ever(controller.messages, (_) {
      _scrollToBottom();
    });
  }
  @override
  void dispose() {
    Get.delete<ChatController>(tag: widget.chatId);
    super.dispose();
  }
  // @override
  // void didChangeMetrics() {
  //   final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
  //
  //   if (bottomInset > 0) {
  //     // Keyboard opened
  //     _scrollToBottom();
  //   }
  // }

  // bool isKeyboardOpen(BuildContext context) {
  //   return MediaQuery.of(context).viewInsets.bottom > 0;
  // }

// keyboard opens -> padding and scroll to bottom
  void _scrollToBottom() {
    if (!scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 50), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = authController.user.value;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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

      //  BODY
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

          return Column(
            children: [

              /// MESSAGES AREA
              Expanded(
                child: Stack(
                  children: [
                    _chatBackground(),

                    ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        // horizontal: Get.width * 0.000,
                        vertical: Get.height * 0.01,   // 1.5% height
                      ),
                      itemCount: controller.messages.length,
                      itemBuilder: (_, i) {
                        final msg = controller.messages[i];
                        final isMe =
                            msg.senderId == authController.user.value!.id;

                        return ChatBubble(
                          message: msg.content,
                          isMe: isMe,
                          time: msg.createdAt,
                          isSeen: isMe ? msg.isSeen : false,
                        );
                      },
                    ),
                  ],
                ),
              ),

              /// INPUT BAR
              _inputBar(),
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
        padding: EdgeInsets.fromLTRB(
          Get.width * 0.04,
          Get.height * 0.004,
          Get.width * 0.04,
          Get.height * 0.015,
        ),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(Get.width * 0.07),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.03,
              vertical: Get.height * 0.006,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Get.width * 0.07),
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

                SizedBox(width: Get.width * 0.02),

                CircleAvatar(
                  radius: Get.width * 0.055,
                  backgroundColor: const Color(0xFF7AB7A7),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      size: Get.width * 0.05,
                      color: Colors.white,
                    ),
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
