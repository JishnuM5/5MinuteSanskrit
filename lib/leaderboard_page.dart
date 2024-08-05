import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'themes.dart';

// This is the leaderboard page
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lbUsers = context.watch<MyAppState>().lbUsers;
    final lbUser = context.read<MyAppState>().lbUser;

    // Some values are preset for the UI of the top 3 users
    const List<Color> topColors = [
      Color.fromARGB(255, 188, 156, 34),
      Color.fromARGB(255, 192, 192, 192),
      Color.fromARGB(255, 205, 127, 50),
    ];
    const List<String> rankEndings = ['st', 'nd', 'rd'];

    // Sort users in descending order, get up to top 10, and get current user's rank
    lbUsers.sort((a, b) => b.lbPoints.compareTo(a.lbPoints));
    final topUsers = lbUsers.take(10).toList();
    final currentUserRank =
        lbUsers.indexWhere((user) => user.name == lbUser.name) + 1;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Leaderboard",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Divider(),
            ),
            const SizedBox(height: 10),
            // The user's statistics and position on the leaderboard
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Your Points:',
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: ConstColors.primary,
                                  ),
                        ),
                        Text(
                          '${lbUser.lbPoints}',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                color: ConstColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 50,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Image(image: AssetImage('assets/trophy.png'), height: 75),
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Your Rank:',
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: ConstColors.primary,
                                  ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$currentUserRank',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      color: ConstColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50,
                                    ),
                              ),
                              TextSpan(
                                text: (currentUserRank > 3)
                                    ? 'th'
                                    : rankEndings[currentUserRank - 1],
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(color: ConstColors.primary),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // This is a list of the top 10 users on the leaderboard
            Padding(
              padding: const EdgeInsets.all(20),
              child: FloatingBox(
                padding: 12.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topUsers.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            // If any of the top 10 users is the current user, the row is highlighted
                            color: (index == currentUserRank - 1)
                                ? ConstColors.shade
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 7.5,
                              horizontal: 7.5,
                            ),
                            // A row contains the user's rank, name, and points
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (index > 2)
                                        ? ConstColors.primary
                                        : topColors[index],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    topUsers[index].name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Image(
                                      image: AssetImage('assets/star.png'),
                                      height: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${topUsers[index].lbPoints}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}