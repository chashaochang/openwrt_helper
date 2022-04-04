import 'package:flutter/material.dart';

import '../model/Menu.dart';

class SecondaryMenu extends StatefulWidget {
  final Menu menus;

  const SecondaryMenu(this.menus, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondaryMenuState();
}

class _SecondaryMenuState extends State<SecondaryMenu> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    var item = widget.menus;
    List<Widget> secondList = [];
    for (var i in item.items) {
      secondList.add(
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 5, 32, 5),
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: Text(i, style: const TextStyle(fontSize: 14)),
            ),
          ),
          onTap: () {},
        ),
      );
    }
    var container = Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16),
                )),
                Visibility(
                    visible: item.items.isNotEmpty,
                    child: Icon(_visible
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down))
              ],
            ),
            onTap: () {
              setState(() {
                _visible = !_visible;
              });
            },
          ),
          Visibility(
            visible: _visible,
            child: Column(
              children: secondList,
            ),
          )
        ],
      ),
    );
    return container;
  }
}
