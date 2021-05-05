import '../common.dart';
import '../data.dart';

class ExpandedType extends StatefulWidget {
  final List<dynamic> currentType;
  final Function chooseTypeFromExpanded;
  ExpandedType(this.currentType, this.chooseTypeFromExpanded);

  @override
  _ExpandedTypeState createState() => _ExpandedTypeState();
}

class _ExpandedTypeState extends State<ExpandedType> {
  List<dynamic> currentType;
  List<dynamic> allTypes = [];
  int localeIndex;
  @override
  void initState() {
    allTypes = Data().getTypes;
    localeIndex = Data().getLocaleIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('$allTypes 454');
    print(currentType);
    print(localeIndex);
    return Container(
      width: 600,
      child: ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          childrenPadding: EdgeInsets.all(10),
          title: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[600],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(currentType == null
                ? widget.currentType == null
                    ? AppLocalizations.of(context).classification
                    : widget.currentType[localeIndex]
                : currentType[localeIndex]),
          ),
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (_, i) => TextButton(
                onPressed: () {
                  setState(() {
                    currentType = allTypes[i];
                    widget.chooseTypeFromExpanded(allTypes[i]);
                  });
                },
                child: Text(allTypes[i][localeIndex]),
              ),
              itemCount: allTypes.length,
            ),
          ]),
    );
  }
}
