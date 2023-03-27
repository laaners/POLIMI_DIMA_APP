import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/widgets/event_list.dart';
import 'package:dima_app/widgets/event_poll_switch.dart';
import 'package:dima_app/widgets/lists_switcher.dart';
import 'package:dima_app/widgets/poll_list.dart';
import 'package:flutter/material.dart';
import '../../widgets/my_app_bar.dart';
import 'profile_info.dart';

class ViewProfileScreen extends StatelessWidget {
  final UserCollection userData;

  const ViewProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: userData.name,
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ListView(children: [
        ProfileInfo(
          userData: userData,
        ),
        const Divider(
          height: 30,
        ),
        ListsSwitcher(
          labels: const ["Events", "Polls"],
          lists: [
            EventList(userUid: userData.uid),
            PollList(userUid: userData.uid)
          ],
        ),
        // EventPollSwitch(userUid: userData.uid),
      ]),
    );
  }
}
