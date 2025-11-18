import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dto/inspection.dart';
import '../../../router/routes.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/image_picker.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/loader.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../shared/widgets/signature_view.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../../profile/providers/return_vehicle_providers.dart';
import '../providers/request_vehicle_inspection_provider.dart';

class RequestVehicleInspectionPage extends ConsumerWidget {
  final InspectionDto dto;

  const RequestVehicleInspectionPage({
    required this.dto,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(requestVehicleInspectionProvider);
    return Loader(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Text(
            LocaleKeys.vehicle_inspection.tr(),
            style: Theme.of(context).primaryTextTheme.displayLarge,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              bottom: 40.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpace(space: 40),
                Text(
                  LocaleKeys.total_traveled_km.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                const VerticalSpace(space: 15),
                PrimaryTextField(
                  hintText: "131 KM",
                  onChanged: (value) {
                    ref.read(totalTraveledProvider.notifier).setKm(value);
                  },
                ),
                const VerticalSpace(space: 25),
                Container(
                  height: 1,
                  color: SECONDARY_TEXT_COLOR,
                ),
                const VerticalSpace(space: 25),
                Text(
                  LocaleKeys.vehicle_inspection.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                const VerticalSpace(space: 15),
                Text(
                  LocaleKeys.vehicle_inspection_description.tr(),
                  style:
                      Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                            color: SECONDARY_TEXT_COLOR,
                          ),
                ),
                const VerticalSpace(space: 30),
                Consumer(
                  builder: (_, ref, __) {
                    final inspectionImages =
                        ref.watch(setInspectionImagesProvider);
                    return Wrap(
                      runSpacing: 14.w,
                      spacing: 12.w,
                      children: inspectionImages.map((e) {
                        return _UploadImage(
                          label: e.label,
                          imagePath: e.imagePath,
                          selectedImagePath: e.selectedImagePath,
                          onTap: () async {
                            final image = await pickImage();

                            if (image == null) return;

                            ref
                                .read(setInspectionImagesProvider.notifier)
                                .setImage(image.path, e.type);
                          },
                          onRemove: () {
                            ref
                                .read(setInspectionImagesProvider.notifier)
                                .removeImage(e.type);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const VerticalSpace(space: 30),
                Consumer(
                  builder: (_, ref, __) {
                    final inspectionImages =
                        ref.watch(setInspectionImagesProvider);
                    final totalTraveled = ref.watch(totalTraveledProvider);

                    final isDisable = totalTraveled == null ||
                        totalTraveled.isEmpty ||
                        inspectionImages.any(
                            (element) => element.selectedImagePath == null);

                    return Button(
                      label: LocaleKeys.send_for_verification.tr(),
                      isDisabled: isDisable,
                      onPressed: () {
                        showBottomModal(
                          context: context,
                          height: 720.w,
                          child: SignatureView(
                            onSigned: (bytes) {
                              if (bytes == null) return;
                              context.pop();

                              ref
                                  .read(
                                      requestVehicleInspectionProvider.notifier)
                                  .submit(
                                      inspectionId: dto.inspectionId,
                                      vehicleTypeId: dto.vehicleId,
                                      signatureBytes: bytes,
                                      onSuccess: () {
                                        context.go(Routes.bottomNav);

                                        showSuccessSnackBar(
                                          context,
                                          message: LocaleKeys
                                              .success_verification_send
                                              .tr(),
                                        );
                                      },
                                      onError: () {
                                        showErrorSnackBar(
                                          context,
                                          messageText: LocaleKeys
                                              .error_failed_to_upload_images
                                              .tr(),
                                        );
                                      });
                            },
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadImage extends StatelessWidget {
  final String label;
  final String imagePath;
  final String? selectedImagePath;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _UploadImage({
    required this.label,
    required this.imagePath,
    this.selectedImagePath,
    required this.onTap,
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: selectedImagePath == null ? onTap : null,
      child: Stack(
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(10.r),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
              ),
              height: 180.w,
              width: 180.w,
              child: selectedImagePath == null
                  ? Ink.image(
                      image: AssetImage(imagePath),
                      fit: BoxFit.contain,
                    )
                  : Ink.image(
                      image: FileImage(
                        File(selectedImagePath!),
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          if (selectedImagePath != null) ...[
            Positioned(
              top: 8.h,
              right: 8.w,
              child: InkWell(
                onTap: onRemove,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ] else ...[
            Positioned(
              top: 8.h,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  label,
                  style: theme.primaryTextTheme.displayMedium!.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8.h,
              child: Center(
                child: Text(
                  LocaleKeys.tap_to_upload.tr(),
                  style: theme.primaryTextTheme.displaySmall!.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
