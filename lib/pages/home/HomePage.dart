import 'dart:convert';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:openwrt_helper/Global.dart';
import 'package:openwrt_helper/pages/home/widget/SecondaryMenu.dart';

import 'model/Menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> menuWidget = [];

  _HomePageState() {
    _getMenu();
    _get();
  }

  _get() async {
    var url = Uri.parse("http://192.168.1.2/cgi-bin/luci/?status=1&_=" +
        DateTime.now().millisecondsSinceEpoch.toString());
    var response = await http.get(url, headers: {"cookie": Global.cookie});
    if (response.statusCode == 403) {
      //跳转登录
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      return;
    }
  }

  _getMenu() async {
    var url = Uri.parse("http://192.168.1.2/cgi-bin/luci/");
    var response = await http.get(url, headers: {"cookie": Global.cookie});
    if (response.statusCode == 403) {
      //跳转登录
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } else if (response.statusCode == 200) {
      Utf8Decoder utf8decoder = const Utf8Decoder();
      List<Menu> menu = parseData(utf8decoder.convert(response.bodyBytes));
      List<Widget> list = [
        const DrawerHeader(
          child: Text("OpenWrt"),
        ),
      ];
      for (var i in menu) {
        list.add(SecondaryMenu(i));
      }
      setState(() {
        menuWidget = list;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    menuWidget = [
      const DrawerHeader(
        child: Text("OpenWrt"),
      ),
      const ListTile(
        title: Text("状态"),
      ),
      const ListTile(
        title: Text("系统"),
      ),
      const ListTile(
        title: Text("服务"),
      ),
      const ListTile(
        title: Text("网络存储"),
      ),
      const ListTile(
        title: Text("VPN"),
      ),
      const ListTile(
        title: Text("网络"),
      ),
      const ListTile(
        title: Text("宽带监控"),
      ),
      const ListTile(
        title: Text("退出"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: menuWidget,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getMenu();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Menu> parseData(String dom) {
    List<Menu> menus = [];
    var document = parse(dom);
    var list = document.getElementsByClassName("nav");
    if (list.isNotEmpty) {
      var nav = list[0];
      var liDropDowns = nav.children;
      for (var e in liDropDowns) {
        var menuItem = Menu();
        var menu = e.getElementsByTagName("a");
        if (menu.isNotEmpty) {
          menuItem.title = menu[0].text;
          print(menu[0].text);
        }
        var secondMenu = e.getElementsByClassName("dropdown-menu");
        if (secondMenu.isNotEmpty) {
          var secondList = secondMenu[0].children;
          for (var li in secondList) {
            var a = li.getElementsByTagName("a");
            if (a.isNotEmpty) {
              menuItem.items.add(a[0].text);
              print(a[0].text);
            }
          }
        }
        menus.add(menuItem);
      }
    }
    return menus;
  }
}
