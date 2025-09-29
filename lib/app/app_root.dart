import 'dart:async';
import 'package:JIR/main.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:JIR/pages/auth/view/reset_password_page.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _handledInitialLink = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialLink = await _appLinks.getInitialLink();
      if (!_handledInitialLink) {
        _handleUri(initialLink);
        _handledInitialLink = true;
      }
    } catch (e) {
      debugPrint('getInitialLink error: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    }, onError: (err) {
      debugPrint('uriLinkStream error: $err');
    });
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;
    debugPrint('Received deep link: $uri');

    var oob = uri.queryParameters['oobCode'] ?? uri.queryParameters['oob_code'];

    if (oob == null || oob.isEmpty) {
      final nested =
          uri.queryParameters['link'] ?? uri.queryParameters['deep_link_id'];
      if (nested != null && nested.isNotEmpty) {
        final nestedDecoded = Uri.decodeFull(nested);
        try {
          final nestedUri = Uri.parse(nestedDecoded);
          oob = nestedUri.queryParameters['oobCode'] ??
              nestedUri.queryParameters['oob_code'];
        } catch (e) {
          debugPrint('Failed to parse nested link: $e; nested: $nestedDecoded');
        }
      }
    }

    if (oob != null && oob.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => ResetPasswordPage(oobCode: oob!));
      });
    } else {
      debugPrint('No oobCode found in link');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}
