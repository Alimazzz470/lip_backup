import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/svg_widget.dart';
import '../bottom_nav_extensions.dart';

class BottomNavBar extends StatelessWidget {
  final void Function(HomePageItem)? onTap;

  BottomNavBar({
    required int currentIndex,
    this.onTap,
    Key? key,
  }) : super(key: key) {
    var currentPage = HomePageItem.values[currentIndex];
    navigationItems = HomePageItem.values
        .map((e) => _NavItem(
            item: e, selectedPage: currentPage, onTap: () => onTap?.call(e)))
        .toList(growable: false);
  }

  late final List<Widget> navigationItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 15.r,
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: Row(children: navigationItems),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final HomePageItem selectedPage;
  final HomePageItem item;
  final VoidCallback onTap;
  late final bool isSelected;

  _NavItem({
    required this.item,
    required this.selectedPage,
    required this.onTap,
    Key? key,
  }) : super(key: key) {
    isSelected = selectedPage == item;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 5.h,
                  width: 28.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                const VerticalSpace(space: 20),
                SvgWidget(
                  imagePath:
                      isSelected ? item.activeIconPath : item.inactiveIconPath,
                  color: Theme.of(context).primaryColor.withOpacity(
                        isSelected ? 1 : 0.5,
                      ),
                  width: 30.r,
                ),
                const VerticalSpace(space: 10),
                Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: Theme.of(context).primaryColor.withOpacity(
                              isSelected ? 1 : 0.5,
                            ),
                      ),
                ),
                const VerticalSpace(space: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
