import 'package:dima_app/server/tables/poll_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/pill_box.dart';
import 'package:dima_app/widgets/profile_pics_stack.dart';
import 'package:flutter/material.dart';
import 'invitees_list.dart';

class InviteesPill extends StatelessWidget {
  final PollCollection pollData;
  final String pollEventId;
  final List<PollEventInviteCollection> invites;
  final VoidCallback refreshPollDetail;
  const InviteesPill({
    super.key,
    required this.pollEventId,
    required this.invites,
    required this.refreshPollDetail,
    required this.pollData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 70),
      child: SizedBox(
        width: 250,
        child: PillBox(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                ProfilePicsStack(
                  radius: 40,
                  offset: 30,
                  uids: invites
                      .map((e) => e.inviteeId)
                      .where((e) => e != pollData.organizerUid)
                      .toList()
                      .sublist(
                          0, invites.length < 4 ? invites.length - 1 : 4 - 1),
                ),
                Container(padding: const EdgeInsets.all(8)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      ScreenTransition(
                        builder: (context) => InviteesList(
                          pollEventId: pollEventId,
                          pollData: pollData,
                          invites: invites
                              .where(
                                  (e) => e.inviteeId != pollData.organizerUid)
                              .toList(),
                          refreshPollDetail: refreshPollDetail,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "${(invites.length - 1).toString()} others voting",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
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
