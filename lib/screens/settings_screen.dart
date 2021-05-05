import '../common.dart';
import 'package:settings_ui/settings_ui.dart';
import '../widgets/app_bar.dart';
import '../data.dart';
import '../widgets/gallery.dart';
import '../widgets/employers_list.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: ArtBar(context, false, null).bar(),
      body: Center(
        child: Container(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: SettingsList(
              darkBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              sections: [
                SettingsSection(
                  title: loc.account,
                  tiles: [
                    SettingsTile(
                      title: loc.open_galery,
                      leading: Icon(Icons.image),
                      onPressed: (_) async {
                        showDialog(
                          context: context,
                          builder: (_) => Gallery(() {}, true, true),
                        );
                      },
                    ),
                    SettingsTile(
                      title: loc.access,
                      leading: Icon(Icons.security),
                      onPressed: (_) => showDialog(
                          context: context,
                          builder: (ctx) => EmployersList(ctx)),
                    ),
                    SettingsTile(
                      title: loc.sign_out,
                      leading: Icon(Icons.logout),
                      onPressed: (_) => Data().logout(context),
                    ),
                    SettingsTile(
                      title: loc.help,
                      leading: Icon(Icons.help),
                      onPressed: (_) => showDialog(
                          context: context,
                          builder: (_) => Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SelectableText(
                                        loc.phone_number,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SelectableText(
                                        loc.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      TextButton(
                                        child: Text(
                                          loc.terms,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .copyWith(fontSize: 15),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => Dialog(
                                                    child: Scrollbar(
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          width: 500,
                                                          child: FutureBuilder(
                                                              future: Data()
                                                                  .loadTerms(),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData)
                                                                  return Center(
                                                                      child:
                                                                          CircularProgressIndicator());
                                                                else if (snapshot
                                                                        .data[
                                                                    'isSuccess'] = true)
                                                                  return Text(
                                                                    snapshot.data[
                                                                        'terms'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  );
                                                              }),
                                                        ),
                                                      ),
                                                    ),
                                                  ));
                                        },
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SelectableText(
                                        '(c) artfmove',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
