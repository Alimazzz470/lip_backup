import 'package:easy_localization/easy_localization.dart';

import '../../shared/helpers/app_assets.dart';
import '../../translations/locale_keys.g.dart';

enum HomePageItem { HOME, LEAVES, TODO_TASKS, PROFILE }

extension HomePageItemExtension on HomePageItem {
  String get activeIconPath {
    switch (this) {
      case HomePageItem.HOME:
        return ACTIVE_HOME_ICON;
      case HomePageItem.LEAVES:
        return ACTIVE_LEAVES_ICON;
      case HomePageItem.TODO_TASKS:
        return TODO_TASK_ACTIVE;
      case HomePageItem.PROFILE:
        return ACTIVE_PROFILE_ICON;
    }
  }

  String get inactiveIconPath {
    switch (this) {
      case HomePageItem.HOME:
        return INACTIVE_HOME_ICON;
      case HomePageItem.LEAVES:
        return INACTIVE_LEAVES_ICON;
      case HomePageItem.TODO_TASKS:
        return TODO_TASK_INACTIVE;
      case HomePageItem.PROFILE:
        return INACTIVE_PROFILE_ICON;
    }
  }

  String get label {
    switch (this) {
      case HomePageItem.HOME:
        return LocaleKeys.bottom_nav_home.tr();
      case HomePageItem.LEAVES:
        return LocaleKeys.bottom_nav_leaves.tr();
      case HomePageItem.TODO_TASKS:
        return LocaleKeys.bottom_nav_todo_tasks.tr();
      case HomePageItem.PROFILE:
        return LocaleKeys.bottom_nav_profile.tr();
    }
  }
}
