import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ailevon/api/login.dart';
import 'package:ailevon/stores/token_manager.dart';
import 'package:ailevon/stores/user_controller.dart';
import 'package:ailevon/utils/widget/loading_dialog.dart';
import 'package:ailevon/utils/widget/toast_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 设置 控制器, 用于绑定为 TextField 的 controller 属性,
  final TextEditingController _usernameController =
      TextEditingController(); // 账号控制器
  final TextEditingController _passwordController =
      TextEditingController(); // 密码控制器

  // Getx 寻找对象
  final UserController _userController = Get.find(); // 寻找对象

  // 账号
  Widget _buildUsernameTextField() {
    return TextFormField(
      // 验证输入
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "用户名或邮箱输入为空";
        }
        return null;
      },
      style: const TextStyle(color: Colors.black),
      controller: _usernameController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 20),
        hintText: "用户名或邮箱",
        fillColor: const Color.fromRGBO(243, 243, 243, 1),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 密码
  Widget _buildPasswordTextField() {
    return TextFormField(
      // 验证输入
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "密码输入为空";
        }
        return null;
      },
      style: const TextStyle(color: Colors.black),
      controller: _passwordController,
      obscureText: true, // 不显示输入的文本
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 20),
        hintText: "密码",
        fillColor: const Color.fromRGBO(243, 243, 243, 1),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 登录按扭
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // 登录逻辑
          if (_formKey.currentState!.validate()) {
            _login();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
        ),
        child: Text("登录", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  //定义一个登入方法
  Future<void> _login() async {
    try {
      // 调用加载组件方法
      LoadingDialog.show(context);

      // 调用登录接口
      final res = await loginAPI({
        "app": "n",
        "password": _passwordController.text,
        "username": _usernameController.text,
      });
      // 进行token持久化
      tokenManager.setToken(res.token ?? ""); // 写入持久化
      // 登录成功后 传入用户信息
      _userController.updateUserInfo(res);
      // print(res.token);
      if (mounted) {
        // 登录完成后, 调用关闭加载组件方法
        LoadingDialog.hide(context);
        ToastUtils2.showToast("登录成功");
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // 登录失败后, 调用关闭加载组件方法
        LoadingDialog.hide(context);
        // print(e.toString());
        ToastUtils2.showToast("登录失败");
      }
    }
  }

  // 声明一个formKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("登录"), centerTitle: true),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.blueGrey,
          child: Center(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  _buildUsernameTextField(),
                  SizedBox(height: 20),
                  _buildPasswordTextField(),
                  SizedBox(height: 20),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
