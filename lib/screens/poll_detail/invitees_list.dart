import 'package:dima_app/screens/error.dart';
import 'package:dima_app/screens/event_create/step_invite.dart';
import 'package:dima_app/screens/poll_detail/locations_list.dart';
import 'package:dima_app/screens/profile/index.dart';
import 'package:dima_app/server/firebase_poll_event_invite.dart';
import 'package:dima_app/server/firebase_user.dart';
import 'package:dima_app/server/tables/poll_event_collection.dart';
import 'package:dima_app/server/tables/poll_event_invite_collection.dart';
import 'package:dima_app/server/tables/user_collection.dart';
import 'package:dima_app/server/tables/vote_date_collection.dart';
import 'package:dima_app/server/tables/vote_location_collection.dart';
import 'package:dima_app/themes/layout_constants.dart';
import 'package:dima_app/transitions/screen_transition.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:dima_app/widgets/my_app_bar.dart';
import 'package:dima_app/widgets/my_button.dart';
import 'package:dima_app/widgets/profile_pic.dart';
import 'package:dima_app/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dima_app/widgets/tabbar_switcher.dart';

class InviteesList extends StatefulWidget {
  final PollEventCollection pollData;
  final String pollEventId;
  final List<PollEventInviteCollection> invites;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationCollection> votesLocations;
  final List<VoteDateCollection> votesDates;
  const InviteesList({
    super.key,
    required this.invites,
    required this.pollEventId,
    required this.refreshPollDetail,
    required this.pollData,
    required this.votesLocations,
    required this.votesDates,
  });

  @override
  State<InviteesList> createState() => _InviteesListState();
}

class _InviteesListState extends State<InviteesList> {
  Future<List<UserCollection>>? _future;
  List<String> users = [];

  @override
  initState() {
    super.initState();
    users = widget.invites.map((e) => e.inviteeId).toList();

    // this list will be passed to step_invite, must filter out from the list
    // the organizer (and the current user itself ? uid != curUid &&)
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    _future =
        Provider.of<FirebaseUser>(context, listen: false).getUsersDataFromList(
            context,
            users
                .where(
                  (uid) => uid != widget.pollData.organizerUid && uid != curUid,
                )
                .toList());
  }

  Future updateInvitees(List<String> newInvitees) async {
    LoadingOverlay.show(context);
    List<String> oldInvitees = widget.invites.map((e) => e.inviteeId).toList();
    // add new invites

    List<String> toAdd =
        newInvitees.where((newId) => !oldInvitees.contains(newId)).toList();
    await Future.wait(toAdd.map((uid) {
      return Provider.of<FirebasePollEventInvite>(context, listen: false)
          .createPollEventInvite(
        context: context,
        pollEventId: widget.pollEventId,
        inviteeId: uid,
      );
    }));

    // delete removed invites, filter out organizer (impossible case but whatever) and curuid
    // ignore: use_build_context_synchronously
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    List<String> toRemove = oldInvitees
        .where((oldId) =>
            !newInvitees.contains(oldId) &&
            oldId != widget.pollData.organizerUid &&
            oldId != curUid)
        .toList();
    await Future.wait(toRemove.map((uid) {
      return Provider.of<FirebasePollEventInvite>(context, listen: false)
          .deletePollEventInvite(
        context: context,
        pollEventId: widget.pollEventId,
        inviteeId: uid,
      );
    }));
    widget.refreshPollDetail();
    // ignore: use_build_context_synchronously
    LoadingOverlay.hide(context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingSpinner();
        }
        if (snapshot.hasError) {
          Future.microtask(() {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => ErrorScreen(
                  errorMsg: snapshot.error.toString(),
                ),
              ),
            );
          });
          return Container();
        }
        if (!snapshot.hasData) {
          return Container();
        }
        List<UserCollection> usersData = snapshot.data!;
        return InviteesListIntermediate(
          pollEventId: widget.pollEventId,
          pollData: widget.pollData,
          users: users,
          updateInvitees: updateInvitees,
          usersDataInitial: usersData,
          refreshPollDetail: widget.refreshPollDetail,
          votesLocations: widget.votesLocations,
          votesDates: widget.votesDates,
          invites: widget.invites,
        );
      },
    );
  }
}

class InviteesListIntermediate extends StatefulWidget {
  final String pollEventId;
  final PollEventCollection pollData;
  final List<PollEventInviteCollection> invites;
  final List<String> users;
  final ValueChanged<List<String>> updateInvitees;
  final List<UserCollection> usersDataInitial;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationCollection> votesLocations;
  final List<VoteDateCollection> votesDates;
  const InviteesListIntermediate({
    super.key,
    required this.pollEventId,
    required this.users,
    required this.updateInvitees,
    required this.usersDataInitial,
    required this.pollData,
    required this.refreshPollDetail,
    required this.votesLocations,
    required this.votesDates,
    required this.invites,
  });

  @override
  State<InviteesListIntermediate> createState() =>
      _InviteesListIntermediateState();
}

class _InviteesListIntermediateState extends State<InviteesListIntermediate> {
  late List<UserCollection> usersData = [];

  @override
  void initState() {
    super.initState();
    usersData = widget.usersDataInitial;
  }

  void addInvitee(UserCollection user) {
    setState(() {
      if (!usersData.map((e) => e.uid).contains(user.uid)) {
        usersData.insert(0, user);
      }
    });
  }

  void removeInvitee(UserCollection user) {
    setState(() {
      usersData.removeWhere((item) => item.uid == user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    var curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    return widget.pollData.organizerUid == curUid || widget.pollData.canInvite
        ? TabbarSwitcher(
            appBarTitle: widget.pollData.pollEventName,
            upRightActions: widget.pollData.organizerUid == curUid ||
                    widget.pollData.canInvite
                ? [
                    TextButton(
                      onPressed: () {
                        widget.updateInvitees(
                            usersData.map((e) => e.uid).toList());
                      },
                      child: const Icon(
                        Icons.done,
                      ),
                    )
                  ]
                : [],
            stickyHeight: 0,
            listSticky: null,
            labels: const ["Partecipants", "Invite"],
            tabbars: [
              usersData.isNotEmpty
                  ? ListView(
                      children: usersData
                          .map((user) => InviteeTile(
                                pollData: widget.pollData,
                                userData: user,
                                refreshPollDetail: widget.refreshPollDetail,
                                votesLocations: widget.votesLocations,
                                votesDates: widget.votesDates,
                                invites: widget.invites,
                                pollEventId: widget.pollEventId,
                              ))
                          .toList(),
                    )
                  : const Center(
                      child: Text("No other partecipants"),
                    ),
              ListView(
                children: [
                  StepInvite(
                    organizerUid: widget.pollData.organizerUid,
                    invitees: usersData,
                    addInvitee: addInvitee,
                    removeInvitee: removeInvitee,
                  ),
                  MyButton(
                    text: "INVITE",
                    onPressed: () {
                      widget
                          .updateInvitees(usersData.map((e) => e.uid).toList());
                    },
                  )
                ],
              )
            ],
          )
        : Scaffold(
            appBar: MyAppBar(
              title: widget.pollData.pollEventName,
              upRightActions: [],
            ),
            body: ResponsiveWrapper(
              child: usersData.isNotEmpty
                  ? ListView(
                      children: usersData
                          .map((user) => InviteeTile(
                                pollData: widget.pollData,
                                userData: user,
                                refreshPollDetail: widget.refreshPollDetail,
                                votesLocations: widget.votesLocations,
                                votesDates: widget.votesDates,
                                invites: widget.invites,
                                pollEventId: widget.pollEventId,
                              ))
                          .toList(),
                    )
                  : const Center(
                      child: Text("No other partecipants"),
                    ),
            ),
          );
  }
}

class InviteeTile extends StatefulWidget {
  final PollEventCollection pollData;
  final UserCollection userData;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationCollection> votesLocations;
  final List<VoteDateCollection> votesDates;
  final String pollEventId;
  final List<PollEventInviteCollection> invites;
  const InviteeTile({
    super.key,
    required this.userData,
    required this.pollData,
    required this.refreshPollDetail,
    required this.votesLocations,
    required this.votesDates,
    required this.pollEventId,
    required this.invites,
  });

  @override
  State<InviteeTile> createState() => _InviteeTileState();
}

class _InviteeTileState extends State<InviteeTile> {
  bool _refresh = false;
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListTile(
        leading: ProfilePic(
          loading: false,
          userData: widget.userData,
          radius: 25,
        ),
        title: Text("${widget.userData.name} ${widget.userData.surname}"),
        subtitle: Text(widget.userData.username),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () async {
          var curUid =
              Provider.of<FirebaseUser>(context, listen: false).user!.uid;
          if (curUid == widget.userData.uid) {
            Widget newScreen = const ProfileScreen();
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          } else {
            Widget newScreen = InviteeVotesScreen(
              pollData: widget.pollData,
              userData: widget.userData,
              refreshPollDetail: widget.refreshPollDetail,
              votesLocations: widget.votesLocations,
              votesDates: widget.votesDates,
              invites: widget.invites,
              pollEventId: widget.pollEventId,
            );
            Navigator.push(
              context,
              ScreenTransition(
                builder: (context) => newScreen,
              ),
            );
          }
        },
      ),
    );
  }
}

class InviteeVotesScreen extends StatefulWidget {
  final PollEventCollection pollData;
  final UserCollection userData;
  final VoidCallback refreshPollDetail;
  final List<VoteLocationCollection> votesLocations;
  final List<VoteDateCollection> votesDates;
  final String pollEventId;
  final List<PollEventInviteCollection> invites;
  const InviteeVotesScreen({
    super.key,
    required this.pollData,
    required this.userData,
    required this.refreshPollDetail,
    required this.votesLocations,
    required this.votesDates,
    required this.pollEventId,
    required this.invites,
  });

  @override
  State<InviteeVotesScreen> createState() => _InviteeVotesScreenState();
}

class _InviteeVotesScreenState extends State<InviteeVotesScreen> {
  bool _refresh = false;

  @override
  Widget build(BuildContext context) {
    return TabbarSwitcher(
      listSticky: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_refresh.toString()),
          ],
        ),
      ),
      stickyHeight: 50,
      labels: const ["Locations", "Dates"],
      appBarTitle: "${widget.userData.username} votes",
      upRightActions: [
        Container(
          margin: const EdgeInsets.only(
            right: LayoutConstants.kHorizontalPadding,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            child: Ink(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Icons.refresh,
              ),
            ),
            onTap: () async {
              widget.refreshPollDetail();
              setState(() {
                print("should refresh");
                _refresh = !_refresh;
              });
            },
          ),
        ),
      ],
      tabbars: [
        LocationsList(
          votingUid: widget.userData.uid,
          organizerUid: widget.pollData.organizerUid,
          pollId: widget.pollEventId,
          locations: widget.pollData.locations,
          invites: widget.invites,
          votesLocations: widget.votesLocations,
        ),
        Text(_refresh.toString())
      ],
    );
  }
}
