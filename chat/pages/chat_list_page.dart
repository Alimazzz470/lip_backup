import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_list_tile.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Chats',
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.canPop() ? context.pop() : context.go(Routes.bottomNav);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          context.push(Routes.create_chat);
        },
        child: const Icon(Icons.add),
      ),
      body: const SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpace(space: 30),
            _ChatList(),
          ],
        ),
      ),
    );
  }
}

class _ChatList extends ConsumerWidget {
  const _ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatList = ref.watch(chatListProvider);

    return chatList.when(
      data: (chats) {
        if (chats.isEmpty) {
          return Expanded(
            child: Center(
              child: Text(
                LocaleKeys.no_chats_found.tr(),
                style:
                    Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                          color: Colors.grey,
                        ),
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 10.h,
            ),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              bool isUserAdmin =
                  ref.read(loggedInUserProvider).id == chats[index].adminId;
              int unreadCount = isUserAdmin
                  ? chats[index].adminUnreadCount
                  : chats[index].userUnreadCount;

              return ChatListTile(
                chat: chats[index],
                isUserAdmin: isUserAdmin,
                unreadCount: unreadCount,
                onTap: () => context.push(
                  Routes.chatDetailsUriWithId(chats[index].id),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const VerticalSpace(space: 20);
            },
          ),
        );
      },
      loading: () {
        return const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stacktrace) {
        return Expanded(
          child: EmptyListPlaceholder(error),
        );
      },
    );
  }
}
