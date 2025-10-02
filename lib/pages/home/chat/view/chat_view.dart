import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/home/chat/controller/chat_controller.dart';
import 'package:JIR/pages/home/chat/widget/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  final ChatController ctrl = Get.put(ChatController());
  late final AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _visualizerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    ctrl.visualizerController = _visualizerController;
  }

  @override
  void dispose() {
    try {
      _visualizerController.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/close_icon.png',
              width: screenWidth * 0.04, height: screenHeight * 0.04),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              top: 150.h,
              left: 0,
              right: 0,
              child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover)),
          Obx(() {
            if (!ctrl.isChatVisible.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.1),
              child: ListView.builder(
                controller: ctrl.scrollController,
                padding: EdgeInsets.all(20.w),
                itemCount: ctrl.messages.length,
                itemBuilder: (context, index) {
                  final m = ctrl.messages[index];
                  return Obx(() {
                    return ChatBubble(
                      key: ValueKey('chat_$index'),
                      message: m,
                      index: index,
                      onPreviewToggle: () => ctrl.togglePreview(index),
                      previewVisible: ctrl.previewVisible.contains(index),
                      onOpenRoute: (route) async {
                        await ctrl.openRouteInMap(route);
                        Get.toNamed(AppRoutes.peta);
                      },
                    );
                  });
                },
              ),
            );
          }),
          Positioned(
              bottom: 0, left: 0, right: 0, child: ChatInput(controller: ctrl)),
          Obx(() {
            if (!ctrl.isMicTapped.value) return const SizedBox.shrink();
            return Center(
                child: MicOverlay(
                    onStop: () => ctrl.stopListening(),
                    controllerValueGetter: _visualizerController));
          }),
        ],
      ),
    );
  }
}
