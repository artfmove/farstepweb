import '../common.dart';
import '../style.dart';

class ExpandedTypes extends StatefulWidget {
  final List<dynamic> types;
  final Function chooseTypes;
  ExpandedTypes(this.types, this.chooseTypes);
  @override
  _ExpandedTypesState createState() => _ExpandedTypesState();
}

class _ExpandedTypesState extends State<ExpandedTypes> {
  List<dynamic> newType = ['', ''];
  AppLocalizations loc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return Container(
      width: 600,
      child: ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          childrenPadding: EdgeInsets.all(10),
          title: Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[600],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(29),
              ),
            ),
            child: Text(AppLocalizations.of(context).classification),
          ),
          children: [
            Form(
              key: _formKey,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (_, i) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.types[i][0],
                            key: UniqueKey(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.types[i][1],
                            key: UniqueKey(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.types.remove(widget.types[i]);
                              });
                            },
                            icon: Icon(Icons.clear),
                          ),
                        ),
                      ],
                    ),
                    itemCount: widget.types.length,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: UniqueKey(),
                          validator: (v) {
                            if (v == '' || v == null)
                              return loc.enter_value;
                            else
                              return null;
                          },
                          onChanged: (v) => newType[0] = v,
                          decoration: CommonStyle.textFieldStyle(
                              ////loc
                              labelTextStr: loc.type_rus),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          key: UniqueKey(),
                          validator: (v) {
                            if (v == '' || v == null)
                              return loc.enter_value;
                            else
                              return null;
                          },
                          onChanged: (v) => newType[1] = v,
                          decoration: CommonStyle.textFieldStyle(
                              labelTextStr: loc.type_ukr),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState.validate() ||
                              newType[0] == '' ||
                              newType[1] == '')
                            return;
                          else {
                            setState(() {
                              widget.types.add(newType);
                              widget.chooseTypes(widget.types);
                              newType = ['', ''];
                            });
                          }
                        },
                        child: Text(loc.add)),
                  )
                ],
              ),
            ),
          ]),
    );
  }
}
