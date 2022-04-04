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
      //登录成功会重定向
      Fluttertoast.showToast(msg: "登录成功");
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
      Fluttertoast.showToast(msg: "网址不正确或不存在");
    } else {
      Fluttertoast.showToast(msg: "用户名或密码错误");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录"),
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
                        labelText: "协议", border: OutlineInputBorder()),
                    controller: _protocol,
                  ),
                ),
                Expanded(
                  child: TextField(
                    maxLines: 1,
                    decoration: const InputDecoration(
                        labelText: "网址/IP", border: OutlineInputBorder()),
                    controller: _domain,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    maxLines: 1,
                    decoration: const InputDecoration(
                        labelText: "端口", border: OutlineInputBorder()),
                    controller: _port,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 1,
              decoration: const InputDecoration(
                  labelText: "用户名", border: OutlineInputBorder()),
              controller: _username,
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 1,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "密码", border: OutlineInputBorder()),
              controller: _password,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Row(
                      children: [
                        const Text("记住密码"),
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
                        const Text("自动登录"),
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
                              title: const Text("提示"),
                              content: const Text("网址/IP不能为空"),
                              actions: [
                                TextButton(
                                  child: const Text("确定"),
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
                              title: const Text("提示"),
                              content: const Text("端口不能为空，http默认80，https默认443"),
                              actions: [
                                TextButton(
                                  child: const Text("确定"),
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
                              title: const Text("提示"),
                              content: const Text("用户名不能为空"),
                              actions: [
                                TextButton(
                                  child: const Text("确定"),
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
                              title: const Text("提示"),
                              content: const Text("密码不能为空"),
                              actions: [
                                TextButton(
                                  child: const Text("确定"),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            );
                          });
                      return;
                    }
                    //本地存储输入的内容
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
                  child: const Text("登录")),
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
                        "我已阅读并同意OpenWrtHelper",
                        style: TextStyle(fontSize: 12),
                      ),
                      InkWell(
                        child: const Text(
                          "用户协议",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        onTap: () {
                          Fluttertoast.showToast(msg: "点击了用户协议");
                        },
                      ),
                      const Text(
                        "和",
                        style: TextStyle(fontSize: 12),
                      ),
                      InkWell(
                        child: const Text(
                          "隐私政策",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        onTap: () {
                          Fluttertoast.showToast(msg: "点击了隐私政策");
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
