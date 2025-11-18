import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxiapp_mobile/core/services/image_helpers.dart';
import 'package:taxiapp_mobile/shared/providers/common_providers.dart';

import '../../../../translations/locale_keys.g.dart';
import '../../../shared/helpers/app_assets.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/loader.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../shared/widgets/svg_widget.dart';
import '../../../shared/widgets/toast.dart';
import '../providers/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInPage> {
  late final GlobalKey<FormState> _formKey;

  String? _username;
  String? _password;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Loader(
          isLoading: ref.watch(authStateNotifierProvider).isLoading,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: PRIMARY_COLOR,
                  width: double.infinity,
                  height: 255.h,
                ),
                const VerticalSpace(space: 60),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.driver_login.tr(),
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w700,
                            color: PRIMARY_TEXT_COLOR,
                          ),
                        ),
                        const VerticalSpace(space: 12),
                        Text(
                          LocaleKeys.sign_in_description.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: SECONDARY_TEXT_COLOR,
                          ),
                        ),
                        const VerticalSpace(space: 30),
                        PrimaryTextField(
                          label: LocaleKeys.enter_email.tr(),
                          hintText: LocaleKeys.email.tr(),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgWidget(
                              imagePath: USER_ICON,
                              width: 10.w,
                              height: 10.w,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return LocaleKeys.required.tr();
                            }

                            if (!isEmailValid(value)) {
                              return LocaleKeys.email_not_valid.tr();
                            }
                            return null;
                          },
                          onChanged: (uName) => _username = uName,
                        ),
                        const VerticalSpace(space: 25),
                        PrimaryTextField(
                          label: LocaleKeys.enter_password.tr(),
                          hintText: "*********",
                          obscureText: true,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgWidget(
                              imagePath: LOCK_ICON,
                              width: 10.w,
                              height: 10.w,
                            ),
                          ),
                          suffixIcon: SuffixIcon.PASSWORD,
                          onChanged: (pwd) => _password = pwd,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                openUrl(
                                    'https://spartrans.site/forgot-password');
                              },
                              child: Text(
                                LocaleKeys.forgot_password.tr(),
                                style: TextStyle(
                                  color: PRIMARY_COLOR,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const VerticalSpace(space: 60),
                        Button(
                          label: LocaleKeys.login.tr(),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              FocusManager.instance.primaryFocus?.unfocus();

                              final fcmToken = await ref
                                  .read(remoteNotificationServiceProvider)
                                  .getFCMToken();

                              ref
                                  .read(authStateNotifierProvider.notifier)
                                  .signIn(
                                    email: _username!,
                                    password: _password!,
                                    fcmToken: fcmToken!,
                                    onError: (error) => showErrorSnackBar(
                                        context,
                                        message: error),
                                  );
                            }
                          },
                        )
                      ],
                    ),
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
