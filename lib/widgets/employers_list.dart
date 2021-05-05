import '../common.dart';
import '../data.dart';
import 'loading_dialog.dart';

class EmployersList extends StatefulWidget {
  final BuildContext ctx;
  EmployersList(this.ctx);
  @override
  _EmployersListState createState() => _EmployersListState();
}

class _EmployersListState extends State<EmployersList> {
  Future loadEmployers;
  List<dynamic> newEmployer = ['', ''];
  AppLocalizations loc;
  void _changeData(data) async {
    LoadingDialog().showLoad(context);
    final success = await Data().uploadEmployers(data);
    LoadingDialog().dispLoad();
    if (!success)
      LoadingDialog().showError(context, 'error');
    else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.changed),
      ));
  }

  @override
  void initState() {
    loadEmployers = Data().loadEmployers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return FutureBuilder(
        future: loadEmployers,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data['success'] == false)
            return Center(child: CircularProgressIndicator());
          return AlertDialog(
            content: Container(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data['employers'].length,
                      itemBuilder: (ctx, i) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  snapshot.data['employers'][i][0],
                                  key: UniqueKey(),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data['employers'][i][1],
                                  key: UniqueKey(),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Container(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      snapshot.data.remove(
                                          snapshot.data['employers'][i]);
                                    });
                                  },
                                  icon: Icon(Icons.clear),
                                ),
                              ),
                            ],
                          )),
                  SizedBox(
                    height: 15,
                  ),
                  Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: UniqueKey(),
                            validator: (v) {
                              if (v == '' || v == null)
                                return loc.enter_mail;
                              else
                                return null;
                            },
                            onChanged: (v) => newEmployer[0] = v,
                            decoration: CommonStyle.textFieldStyle(
                                labelTextStr: loc.mail),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            key: UniqueKey(),
                            validator: (v) {
                              if (v == '' || v == null)
                                return loc.enter_second_name;
                              else
                                return null;
                            },
                            onChanged: (v) => newEmployer[1] = v,
                            decoration: CommonStyle.textFieldStyle(
                                labelTextStr: loc.second_name),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState.validate() ||
                              newEmployer[0] == '' ||
                              newEmployer[1] == '')
                            return;
                          else {
                            setState(() {
                              snapshot.data['employers'].add(newEmployer);

                              newEmployer = ['', ''];
                            });
                          }
                        },
                        child: Text(loc.add)),
                  ),
                  ElevatedButton(
                      onPressed: () => _changeData(snapshot.data['employers']),
                      child: Text(loc.change_data)),
                ],
              ),
            ),
          );
        });
  }
}
