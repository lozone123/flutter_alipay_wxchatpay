import 'package:encrypt_plugin_example/pay/pay_page.dart';
import 'package:flutter/material.dart';

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child:MaterialButton(child:Text('支付',style: TextStyle(fontSize: 24),),
          onPressed: (){
            Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
              return PayPage();
            }));
          },),
      ),
    );
  }
}
