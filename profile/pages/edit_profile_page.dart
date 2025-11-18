import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/entities/user_details.dart';
import '../../../network/models/input/user_details_input.dart';
import '../../../shared/helpers/app_assets.dart';
import '../../../shared/utils/image_picker.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/loader.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController mobileNumberController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController addressController;
  late final TextEditingController additionalAddressController;
  late final TextEditingController countryController;
  late final TextEditingController cityController;
  late final TextEditingController postalCodeController;
  late final TextEditingController bankNameController;
  late final TextEditingController ibanController;
  late final TextEditingController bicController;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    addressController = TextEditingController();
    additionalAddressController = TextEditingController();
    countryController = TextEditingController();
    cityController = TextEditingController();
    postalCodeController = TextEditingController();
    bankNameController = TextEditingController();
    ibanController = TextEditingController();
    bicController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    additionalAddressController.dispose();
    countryController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    bankNameController.dispose();
    ibanController.dispose();
    bicController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void setDataToTextFields(UserDetails user) {
    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    mobileNumberController.text = user.mobilePhone;
    emailController.text = user.email;
    addressController.text = user.address ?? '';
    additionalAddressController.text = user.additionalAddress ?? '';
    countryController.text = user.country ?? '';
    cityController.text = user.city ?? '';
    postalCodeController.text = user.postalCode ?? '';
    bankNameController.text = user.bankName ?? '';
    ibanController.text = user.iBan ?? '';
    bicController.text = user.bic ?? '';
  }

  void saveChanges() {
    final avatar = ref.read(avatarProvider);

    final userDetailsInput = UserDetailsInput(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      mobilePhone: mobileNumberController.text,
      personalEmail: emailController.text,
      address: addressController.text,
      additionalAddress: additionalAddressController.text,
      country: countryController.text,
      city: cityController.text,
      postalCode: postalCodeController.text,
      bankName: bankNameController.text,
      iBan: ibanController.text,
      bic: bicController.text,
      avatar: avatar != null,
      password:
          passwordController.text.isEmpty ? null : passwordController.text,
    );

    ref.read(updateProfileProvider.notifier).update(
        userDetailsInput: userDetailsInput,
        onSuccess: () {
          showSuccessSnackBar(context, message: 'Profile updated successfully');
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Loader(
      isLoading: ref.watch(userDetailsProvider).isLoading ||
          ref.watch(updateProfileProvider),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.edit_profile.tr(),
            style: theme.primaryTextTheme.displayLarge,
          ),
        ),
        body: ref.watch(userDetailsProvider).whenOrNull(
          data: (details) {
            setDataToTextFields(details);
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const VerticalSpace(space: 30),
                      _PersonalDetails(
                        avatar: details.avatar,
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        mobileNumberController: mobileNumberController,
                        emailController: emailController,
                        passwordController: passwordController,
                      ),
                      const VerticalSpace(space: 30),
                      _Address(
                        addressController: addressController,
                        additionalAddressController:
                            additionalAddressController,
                        countryController: countryController,
                        cityController: cityController,
                        postalCodeController: postalCodeController,
                      ),
                      const VerticalSpace(space: 20),
                      _BankDetails(
                        bankNameController: bankNameController,
                        ibanController: ibanController,
                        bicController: bicController,
                      ),
                      const VerticalSpace(space: 20),
                      Button(
                        label: LocaleKeys.save_changes.tr(),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            saveChanges();
                          }
                        },
                      ),
                      const VerticalSpace(space: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PersonalDetails extends ConsumerWidget {
  final String? avatar;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController mobileNumberController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _PersonalDetails({
    required this.avatar,
    required this.firstNameController,
    required this.lastNameController,
    required this.mobileNumberController,
    required this.emailController,
    required this.passwordController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              Consumer(
                builder: (_, ref, __) {
                  final newAvatar = ref.watch(avatarProvider);
                  return newAvatar != null
                      ? CircleAvatar(
                          radius: 50.r,
                          backgroundImage: AssetImage(newAvatar.path),
                        )
                      : CircleAvatar(
                          radius: 50.r,
                          backgroundImage:
                              NetworkImage(avatar ?? USER_PLACEHOLDER_IMAGE),
                        );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  child: CircleAvatar(
                    radius: 15.r,
                    backgroundColor: theme.primaryColor,
                    child: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        width: ScreenUtil().screenWidth,
                        child: Column(
                          children: [
                            const VerticalSpace(space: 40),
                            Text(
                              'Please Select Image Source',
                              style: theme.primaryTextTheme.displayLarge,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                pickImage(source: ImageSource.gallery)
                                    .then((image) {
                                  if (image != null) {
                                    ref
                                        .read(avatarProvider.notifier)
                                        .update(image);
                                  }
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: ScreenUtil().screenWidth,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  height: 55.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.photo,
                                        size: 25,
                                      ),
                                      const HorizontalSpace(
                                        space: 15,
                                      ),
                                      Text(
                                        'Use Gallery',
                                        style: theme
                                            .primaryTextTheme.labelMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )),
                            ),
                            const VerticalSpace(space: 30),
                            GestureDetector(
                              onTap: () {
                                pickImage().then((image) {
                                  if (image != null) {
                                    ref
                                        .read(avatarProvider.notifier)
                                        .update(image);
                                  }
                                });
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: ScreenUtil().screenWidth,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  height: 55.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 25,
                                      ),
                                      const HorizontalSpace(
                                        space: 15,
                                      ),
                                      Text(
                                        'Use Camera',
                                        style: theme
                                            .primaryTextTheme.labelMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: ScreenUtil().screenWidth,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                ),
                                height: 55.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: Colors.red,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: theme.primaryTextTheme.labelMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                            const VerticalSpace(space: 40),
                          ],
                        ),
                      ),
                      // child: Column(
                      //   children: [
                      //     ListTile(
                      //       leading: Icon(Icons.camera_alt),
                      //       title: Text('Use Camera'),
                      //       onTap: () {
                      //         pickImage().then((image) {
                      //           if (image != null) {
                      //             ref
                      //                 .read(avatarProvider.notifier)
                      //                 .update(image);
                      //           }
                      //         });

                      //         Navigator.pop(context);
                      //       },
                      //     ),
                      //     ListTile(
                      //       leading: Icon(Icons.photo),
                      //       title: Text('Choose from Gallery'),
                      //       onTap: () {
                      //         pickImage(source: ImageSource.gallery)
                      //             .then((image) {
                      //           if (image != null) {
                      //             ref
                      //                 .read(avatarProvider.notifier)
                      //                 .update(image);
                      //           }
                      //         });
                      //         Navigator.pop(context);
                      //       },
                      //     ),
                      //   ],
                      // ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalSpace(space: 30),
        Text(
          LocaleKeys.personal_details.tr(),
          style: theme.primaryTextTheme.displayMedium,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: firstNameController,
          hintText: LocaleKeys.first_name.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: lastNameController,
          hintText: LocaleKeys.last_name.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: mobileNumberController,
          hintText: LocaleKeys.mobile_number.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: emailController,
          hintText: LocaleKeys.personal_email.tr(),
          validator: _validate,
        ),
      ],
    );
  }
}

String? _validate(String? value) {
  if (value!.isEmpty) {
    return LocaleKeys.required.tr();
  }
  return null;
}

class _Address extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController additionalAddressController;
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;

  const _Address({
    required this.addressController,
    required this.additionalAddressController,
    required this.countryController,
    required this.cityController,
    required this.postalCodeController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.address.tr(),
          style: theme.primaryTextTheme.displayMedium,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: addressController,
          hintText: LocaleKeys.address.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: additionalAddressController,
          hintText: LocaleKeys.additional_address.tr(),
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: countryController,
          hintText: LocaleKeys.country.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: cityController,
          hintText: LocaleKeys.city.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: postalCodeController,
          hintText: LocaleKeys.postal_code.tr(),
          validator: _validate,
        ),
      ],
    );
  }
}

class _BankDetails extends StatelessWidget {
  final TextEditingController bankNameController;
  final TextEditingController ibanController;
  final TextEditingController bicController;

  const _BankDetails({
    required this.bankNameController,
    required this.ibanController,
    required this.bicController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.bank_details.tr(),
          style: theme.primaryTextTheme.displayMedium,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: bankNameController,
          hintText: LocaleKeys.bank_name.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: ibanController,
          hintText: LocaleKeys.iban.tr(),
          validator: _validate,
        ),
        const VerticalSpace(space: 20),
        PrimaryTextField(
          controller: bicController,
          hintText: LocaleKeys.bic.tr(),
          validator: _validate,
        ),
      ],
    );
  }
}
