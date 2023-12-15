import 'package:flutter/material.dart';
import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/util/AprilJokes.dart';

class TeamsComponent extends StatefulWidget {
  ///
  final String? userKey;

  ///
  const TeamsComponent({Key? key, this.userKey}) : super(key: key);

  @override
  _TeamsState createState() => _TeamsState();
}

class _TeamsState extends State<TeamsComponent> {
  ///
  late List<String> _teams = <String>[];

  @override
  void initState() {
    super.initState();

    _teams = ["Testteam", "Testteam2", "Azubis", "Frontend"];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: Card(
        elevation: 8.0,
        shadowColor: Colors.grey.withAlpha(32),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListView.builder(
          itemCount: _teams.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
              child: Container(
                color: Theme
                    .of(context)
                    .textTheme
                    .bodyText1
                    ?.color
                    ?.withAlpha(50),
                child: Text(_teams[index]),
              ),
            );
          },
        ),
      ),
      title: Localizer.translate(context, 'lblTeams'),
    );
  }
}
