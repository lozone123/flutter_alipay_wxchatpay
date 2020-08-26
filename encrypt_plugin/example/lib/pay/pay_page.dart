
import 'dart:math';

import 'package:encrypt_plugin_example/pay/order_info_util.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alipay/flutter_alipay.dart';
//import 'package:encrypt_plugin/encrypt_plugin.dart';

import 'alipay_config.dart';

class PayPage extends StatefulWidget {
  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  String payResult="";
  String signOrderStr="";//加密用的订单信息，这一串先不需要编码
  var strOrderxx="app_id=2021001185601579&biz_content={\"timeout_express\":\"60m\",\"product_code\":\"QUICK_MSECURITY_PAY\",\"total_amount\":\"1\",\"subject\":\"测试\",\"body\":\"付款\",\"out_trade_no\":\"819171233638406\"}&charset=utf-8&method=alipay.trade.app.pay&sign_type=RSA2&timestamp=2020-08-19 15:50:53&version=1.0&sign=ZKodpzShglhrNb6kCVmX+LwB4OwSOPifxJu/oly9PACeMN+8pg0mKBCSYpwlOfWebuWhw5ylMRKkfsTFwXOcBUursLv9wHtk9wAVJwo0gxR8qZap0zhSRNHdvQ7B/Y360i1tcyKSETk0Vu8gyYZ466oirre9NIyS73TX1rcnO13WIjeVj444eJ4r8ngy2NMsxvZmvILYS2oejCHjMivA0uhbhpzAn2km7X0pDrfXTawP3xfi8TY6CRtprkuWWHKmY0y/bLbHuszeTqcwR8zlszyKsQFditYsReZM32Kj6hgh5imT/VLp203RVrPeJIxkwgYkvzKkHLT2KH7Yfa8w7w==";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              children: <Widget>[
                Center(
                  child: RaisedButton(
                    onPressed: () async {
                      String orderInfo = getOrderInfoForAlipay(
                          "imac1233", "苹果电脑很好用", "1.00", "201212226");
                      String signStr = await FlutterAlipay.sign(
                          signOrderStr, AlipayConfig.RSA_PRIVATE);
                      final String payInfo = orderInfo +
                          "&sign=" +
                          Uri.encodeComponent(signStr);
                      print(payInfo);
                      var result = await FlutterAlipay.pay(payInfo);
                      setState(() {
                        payResult=result.result;
                        print(payResult);
                      });
                      print(result);
                    },
                    child: Text("支付宝付款"),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {},
                    child: Text("微信支付"),
                  ),
                ),
                Text(payResult)
              ],
            )));
  }

  /**
	 * create the order info. 创建订单信息
	 * 
	 */
  String getOrderInfoForAlipay(
      String subject, String body, String price, String orderNo) {
    String orderInfo;

    var orderMap = OrderInfoUtil.buildOrderParamMap(AlipayConfig.app_id, true);
    orderMap.putIfAbsent(
        "biz_content",
        () =>
            "{\"timeout_express\":\"30m\",\"product_code\":\"QUICK_MSECURITY_PAY\",\"total_amount\":\"$price\",\"subject\":\"$subject\",\"body\":\"$body\",\"out_trade_no\":\"" +
            getOutTradeNo() +
            "\"}");
    //排序
    //需要编码
    signOrderStr=OrderInfoUtil.buildOrderParamAndSort(orderMap, false);
    orderInfo = OrderInfoUtil.buildOrderParamAndSort(orderMap,true);
    // extern_token为经过快登授权获取到的alipay_open_id,带上此参数用户将使用授权的账户进行支付
    // orderInfo += "&extern_token=" + "\"" + extern_token + "\"";

    // 支付宝处理完请求后，当前页面跳转到商户指定页面的路径，可空
    //orderInfo += "&return_url=\"\"";

    // 调用银行卡支付，需配置此参数，参与签名， 固定值 （需要签约《无线银行卡快捷支付》才能使用）
    // orderInfo += "&paymethod=\"expressGateway\"";

    return orderInfo;
  }

  /**
	 * 要求外部订单号必须唯一。
	 * @return
	 */
  static String getOutTradeNo() {
    DateTime dateTime = DateTime.now();
    String key =
        "${dateTime.month}${dateTime.day}${dateTime.hour}${dateTime.minute}${dateTime.second}";

    Random r = new Random();
    for(var i=0;i<10;i++){
      key = key + r.nextInt(100).toString();
    }
   
    print(key);
    key = key.substring(0, 20);
    return key;
  }
}
