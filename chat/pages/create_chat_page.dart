import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/shared/helpers/app_assets.dart';
import 'package:taxiapp_mobile/shared/widgets/primary_text_field.dart';
import 'package:taxiapp_mobile/shared/widgets/svg_widget.dart';

import '../../../router/routes.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/create_chat_provider.dart';
import '../widgets/chat_admin_tile.dart';

class CreateChatPage extends StatefulWidget {
  const CreateChatPage({super.key});

  @override
  State<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  late final GlobalKey<FormState> _formKey;

  String? _username;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.create_chat.tr(),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
      ),
      body: Consumer(
        builder: (_, ref, __) {
          final chatAdmins = ref.watch(chatAdminsProvider(_username ?? ''));
          return Column(
            children: [
              const VerticalSpace(
                space: 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
                child: PrimaryTextField(
                  hintText: 'Search Admin...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgWidget(
                      imagePath: SEARCH_ICON,
                      width: 10.w,
                      height: 10.w,
                    ),
                  ),
                  onChanged: (uName) {
                    EasyDebounce.debounce(
                        'my-debouncer', const Duration(milliseconds: 500), () {
                      setState(() {
                        _username = uName;
                      });
                    } // <-- The target method
                        );
                  },
                ),
              ),
              const VerticalSpace(
                space: 10,
              ),
              Expanded(
                child: chatAdmins.when(
                  data: (admins) {
                    if (admins.isEmpty) {
                      return Center(
                        child: Text(
                          LocaleKeys.no_admins_found.tr(),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displaySmall!
                              .copyWith(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 20.h,
                      ),
                      itemCount: admins.length,
                      itemBuilder: (context, index) {
                        return ChatAdminTile(
                          admin: admins[index],
                          onTap: () {
                            ref.read(createChatProvider.notifier).createChat(
                              admins[index].id,
                              (data) {
                                context.pop();

                                context.push(Routes.chatDetails, extra: data);
                              },
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const VerticalSpace();
                      },
                    );
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  error: (error, stacktrace) {
                    return EmptyListPlaceholder(error);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
