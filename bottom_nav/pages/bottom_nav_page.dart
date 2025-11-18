import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/providers/websocket_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/toast.dart';
import '../../home/providers/inspection_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/has_inspection_body.dart';
import '../widgets/has_update_body.dart';

class BottomNavPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavPage({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  ConsumerState<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends ConsumerState<BottomNavPage>
    with WidgetsBindingObserver {
  bool _isInspectionModalOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.scheduleFrameCallback((_) {
      ref.read(remoteNotificationServiceProvider).startHandlers();
      ref.read(remoteNotificationServiceProvider).setNotificationToken();
      _checkUpdate();
      _checkInspection();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      ref.read(webSocketProvider).closeConnection();

      if (_isInspectionModalOpen) {
        context.pop();
        _isInspectionModalOpen = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      ref.read(webSocketProvider).connect();
      ref.read(remoteNotificationServiceProvider).setNotificationToken();
      _checkUpdate();
      _checkInspection();
    }
  }

  void _checkUpdate() async {
    final shorebirdCodePush = ShorebirdCodePush();

    final isUpdateAvailable =
        await shorebirdCodePush.isNewPatchAvailableForDownload();

    if (isUpdateAvailable) {
      await shorebirdCodePush.downloadUpdateIfAvailable();

      _showUpdateModal();
    }
  }

  Future<void> _checkInspection() async {
    final hasInspection =
        await ref.read(hasInspectionProvider.notifier).check();

    if (hasInspection != null && hasInspection.is30Days) {
      _showInspectionModal(
        hasInspection.id,
        hasInspection.vehicleId,
      );
    }
  }

  Future<void> _showUpdateModal() async {
    showBottomModal(
      context: context,
      height: 0.8.sw,
      isDismissible: false,
      isDraggable: false,
      child: const HasUpdateBody(),
    );
  }

  Future<void> _showInspectionModal(
    String inspectionId,
    String vehicleId,
  ) async {
    _isInspectionModalOpen = true;
    showBottomModal(
      context: context,
      height: 0.8.sw,
      isDismissible: false,
      isDraggable: false,
      child: HasInspectionBody(inspectionId, vehicleId),
    ).then((_) {
      _isInspectionModalOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<(CodedException?, RetryFunction)>(appMessageProvider,
        (_, message) {
      showErrorSnackBar(
        context,
        message: message.$1,
        retry: message.$2,
      );
    });

    // Connect to the web socket by adding a listener
    ref.listen(webSocketProvider, (_, __) {});

    // Listen to fcm messages to keep it alive on logged in state
    ref.listen(remoteNotificationServiceProvider, (_, __) {});

    final String location = GoRouterState.of(context).uri.toString();

    debugPrint('Current location: $location');

    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: BACKGROUND_COLOR,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: BottomNavBar(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: (item) => _onTap(context, item.index),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
