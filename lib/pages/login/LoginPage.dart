import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:openwrt_helper/CacheConfig.dart';
import 'package:openwrt_helper/Global.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _protocol = TextEditingController();
  final _domain = TextEditingController();
  final _port = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _memorizePwd = false;
  var _autoLogin = false;
  var _readed = false;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _protocol.text = "http";
    _domain.text = "";
    _port.text = "80";
    _username.text = "";
    _password.text = "";
    super.initState();
    _prefs.then((prefs) {
      var domain = prefs.getString(CacheConfig.loginDomain) ?? "";
      var port = prefs.getString(CacheConfig.loginPort) ?? "80";
      var username = prefs.getString(CacheConfig.loginUsername) ?? "";
      var password = prefs.getString(CacheConfig.loginPassword) ?? "";
      var autoLogin = prefs.getBool(CacheConfig.loginAuto) ?? false;
      setState(() {
        _domain.text = domain;
        _port.text = port;
        _username.text = username;
        if (password.isNotEmpty) _memorizePwd = true;
        _autoLogin = autoLogin;
        if (autoLogin) {
          _login();
        }
      });
    });
  }

  _login() async {
    var url = Uri.parse(_protocol.text +
        "://" +
        _domain.text +
        ":" +
        _port.text +
        "/cgi-bin/luci/");
    var res = await http.post(url, body: {
      "luci_username": _username.text,
      "luci_password": _password.text
    });
    if (res.statusCode == 302) {
      //print(res.headers['set-cookie']);
      Global.cookie = res.headers['set-cookie'] ?? "";
      //????????????????????????
      Fluttertoast.showToast(msg: "????????????");
      _prefs.then((prefs) {
        if (_memorizePwd) {
          prefs.setString(CacheConfig.loginPassword, _password.text);
        }
        if (_autoLogin) {
          prefs.setBool(CacheConfig.loginAuto, true);
        }
        if (_readed) {
          prefs.setBool(CacheConfig.loginAllow, true);
        }
      });
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } else if (res.statusCode == 404) {
      Fluttertoast.showToast(msg: "???????????????????????????");
    } else {
      Fluttertoast.showToast(msg: "????????????????????????");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("??????"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    enabled: false,
                    maxLines: 1,
                    decoration: const InputDecoration(
                        labelText: "??????", border: OutlineInputBorder()),
                    controller: _protocol,
                  ),
                ),
                Expanded(
                  child: TextField(
                    maxLines: 1,
                    decoration: const InputDecoration(
                        labelText: "??????/IP", border: OutlineInputBorder()),
                    controller: _domain,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    maxLines: 1,
                    decoration: const InputDecoration(
                        labelText: "??????", border: OutlineInputBorder()),
                    controller: _port,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 1,
              decoration: const InputDecoration(
                  labelText: "?????????", border: OutlineInputBorder()),
              controller: _username,
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 1,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "??????", border: OutlineInputBorder()),
              controller: _password,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Row(
                      children: [
                        const Text("????????????"),
                        Checkbox(
                          value: _memorizePwd,
                          onChanged: (bool? value) {},
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _memorizePwd = !_memorizePwd;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Row(
                      children: [
                        const Text("????????????"),
                        Checkbox(
                          value: _autoLogin,
                          onChanged: (bool? value) {},
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _autoLogin = !_autoLogin;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    if (_domain.text.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text("??????"),
                              content: const Text("??????/IP????????????"),
                              actions: [
                                TextButton(
                                  child: const Text("??????"),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          });
                      return;
                    }
                    if (_port.text.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text("??????"),
                              content: const Text("?????????????????????http??????80???https??????443"),
                              actions: [
                                TextButton(
                                  child: const Text("??????"),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          });
                      return;
                    }
                    if (_username.text.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text("??????"),
                              content: const Text("?????????????????????"),
                              actions: [
                                TextButton(
                                  child: const Text("??????"),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          });
                      return;
                    }
                    if (_password.text.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text("??????"),
                              content: const Text("??????????????????"),
                              actions: [
                                TextButton(
                                  child: const Text("??????"),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          });
                      return;
                    }
                    //???????????????????????????
                    _prefs.then((prefs) {
                      prefs.setString(
                          CacheConfig.loginProtocol, _protocol.text);
                      prefs.setString(CacheConfig.loginDomain, _domain.text);
                      prefs.setString(CacheConfig.loginPort, _port.text);
                      prefs.setString(
                          CacheConfig.loginUsername, _username.text);
                    });
                    _login();
                  },
                  child: const Text("??????")),
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _readed,
                        onChanged: (bool? value) {
                          setState(() {
                            _readed = !_readed;
                          });
                        },
                      ),
                      const Text(
                        "?????????????????????OpenWrtHelper",
                        style: TextStyle(fontSize: 12),
                      ),
                      InkWell(
                        child: const Text(
                          "????????????",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        onTap: () {
                          Fluttertoast.showToast(msg: "?????????????????????");
                        },
                      ),
                      const Text(
                        "???",
                        style: TextStyle(fontSize: 12),
                      ),
                      InkWell(
                        child: const Text(
                          "????????????",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        onTap: () {
                          Fluttertoast.showToast(msg: "?????????????????????");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
