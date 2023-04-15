import 'package:dima_app/screens/event_create/index.dart';
import 'package:dima_app/screens/event_create/step_invite.dart';
import 'package:dima_app/screens/poll_detail/index.dart';
import 'package:dima_app/server/firebase_poll.dart';
import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/gmaps.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/my_app_bar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Events",
        upRightActions: [MyAppBar.SearchAction(context)],
      ),
      body: ResponsiveWrapper(
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () {
                // ignore: use_build_context_synchronously
                String pollId =
                    "Event 0 of UsernameId14_0DmBO8Fw0ofrK9RbXIO4dYlEIg03";
                Widget newScreen = PollDetailScreen(
                  pollId: pollId,
                );
                Navigator.push(
                  context,
                  ScreenTransition(builder: (context) => newScreen),
                );
              },
              child: const Text("TO POLL DETAIL (WITH TABBAR)"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  ScreenTransition(
                    builder: (context) => const EventCreateScreen(),
                  ),
                );
              },
              child: const Text("TO EVENT CREATE"),
            ),
            ElevatedButton(
              onPressed: () async {
                LoadingOverlay.show(context);
                /*
                await showModalBottomSheet(
                  useRootNavigator: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: Scaffold(
                      body: ResponsiveWrapper(
                        child: Container(
                            // margin: const EdgeInsets.only(top: 15, bottom: 15),
                            child: GmapFromCoor(
                          address: "ok",
                          lat: 50,
                          lon: 50,
                        )),
                      ),
                    ),
                  ),
                );
                */
              },
              child: const Text("map test"),
            ),
          ],
        ),
      ),
    );
  }
}
