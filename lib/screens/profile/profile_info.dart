import 'package:dima_app/server/tables/user_collection.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final UserCollection? userData;

  const ProfileInfo({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '@${userData!.username}',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Text("${userData?.name} ${userData?.surname}",
            style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
