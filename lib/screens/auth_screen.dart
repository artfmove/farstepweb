import '../common.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../widgets/loading_dialog.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AppLocalizations loc;
  Map<String, String> authData = {'login': '', 'password': ''};

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            bottom: PreferredSize(
                child: Container(
                  color: Colors.orange,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(4.0)),
            title: Text(AppLocalizations.of(context).authorization),
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        key: UniqueKey(),
                        decoration: CommonStyle.textFieldStyle(
                          labelTextStr: loc.login,
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          authData['login'] = value;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        key: UniqueKey(),
                        decoration: CommonStyle.textFieldStyle(
                          labelTextStr: loc.password,
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          authData['password'] = value;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      signButton(context, authData),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          content: Text(loc.support_contacts),
                                          actions: [
                                            TextButton(
                                              child: Text(loc.ok),
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                            )
                                          ],
                                        ));
                              },
                              child: Text(loc.trouble,
                                  style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ));
  }

  Widget signButton(context, authData) {
    return Container(
        height: 100,
        child: Center(
            child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState.validate()) return;
                  LoadingDialog().showLoad(context);
                  final signInResponse =
                      await Provider.of<Data>(context, listen: false).signIn(
                          context, authData['login'], authData['password']);
                  if (!signInResponse['isSuccessful']) {
                    LoadingDialog().dispLoad();
                    LoadingDialog().showError(
                        context,
                        signInResponse['errorMessage'] != null
                            ? signInResponse['errorMessage']
                            : loc.error_go_support);
                  }
                  setState(() {});
                },
                child: Text(loc.sign_in))));
  }
}
