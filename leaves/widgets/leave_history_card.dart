import 'package:flutter/material.dart';

import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_card.dart';

class LeaveHistoryCard extends StatelessWidget {
  const LeaveHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sick Leave",
            style: Theme.of(context).primaryTextTheme.displaySmall,
          ),
          const VerticalSpace(space: 5),
          Text(
            "23 June - 26. June",
            style: Theme.of(context).primaryTextTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
