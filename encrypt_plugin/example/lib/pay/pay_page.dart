
import 'dart:math';

import 'package:encrypt_plugin_example/pay/order_info_util.dart';
import 'package:encrypt_plugin_example/pay/wxpay_config.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_plugin/encrypt_plugin.dart';
import 'package:fluwx_pay_only/fluwx_pay_only.dart' as fluwx;
import 'alipay_config.dart';
import 'wx_pay.dart';


class PayPage extends StatefulWidget {
  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  String payResult="";
  String signOrderStr="";//加密用的订单信息，这一串先不需要编码
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
                    onPressed: ()  async{
  //获取prepayId
                      var result = await WxPay.doPay(
                          "beijing-shanghai-train", getOutTradeNo(), "100");
                      //调起微信，完成支付
                      fluwx
                          .pay(
                        appId: WxPayConfig.APPID,
                        partnerId: WxPayConfig.mch_id,
                        prepayId: result['prepayId'].toString(),
                        packageValue: "Sign=WXPay",
                        nonceStr: result['nonceStr'].toString(),
                        timeStamp: int.parse(result['timeStamp']),
                        sign: result['sign'].toString(),
                      )
                          .then((data) {
                        print("---》$data");
                      });

},
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
