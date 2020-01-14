
import 'package:flutter/material.dart';
import 'package:flutter_alipay/flutter_alipay.dart';
import 'package:encrypt_plugin/encrypt_plugin.dart';

import 'alipay_config.dart';

class PayPage extends StatefulWidget {
  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
          children: <Widget>[
            MaterialButton(
              onPressed: () async {
                String orderInfo =
                    getOrderInfoForAlipay("测试", "支付宝付款", "0.01", "201212226");
                String signStr =
                    await EncryptPlugin.sign(orderInfo, AlipayConfig.RSA_PRIVATE);
                final String payInfo = orderInfo +
                    "&sign=\"" +
                    signStr +
                    "\"&" +
                    "sign_type=\"RSA\"";
                print(payInfo);
                var result = await FlutterAlipay.pay(payInfo);
                print(result);
              },
              child:Image.asset("assets/images/alipay_cn_icon.png"),
            ),
            SizedBox(height: 5,),
            MaterialButton(
              onPressed: () {},
              child: Image.asset("assets/images/we_pay_logo.png"),
            )
          ],
        )));
  }

  /**
	 * create the order info. 创建订单信息
	 * 
	 */
  String getOrderInfoForAlipay(
      String subject, String body, String price, String orderNo) {
    // 签约合作者身份ID
    String orderInfo = "partner=" + "\"" + AlipayConfig.PARTNER + "\"";

    // 签约卖家支付宝账号
    orderInfo += "&seller_id=" + "\"" + AlipayConfig.SELLER + "\"";

    // 商户网站唯一订单号
    orderInfo += "&out_trade_no=" + "\"" + orderNo + "\"";

    // 商品名称
    orderInfo += "&subject=" + "\"" + subject + "\"";

    // 商品详情
    orderInfo += "&body=" + "\"" + body + "\"";

    // 商品金额
    orderInfo += "&total_fee=" + "\"" + price + "\"";

    // 服务器异步通知页面路径
    String reqUrl = "http://xxx.xxx.com/";
//		String params = "?orderid=" +orderNo+ "&syschtTUID=" + GlobalUtil.UID;
//		params += "&lgc="+GlobalUtil.LGC +"&status=OKAL";
//		reqUrl=reqUrl+params;
    orderInfo += "&notify_url=" + "\"" + reqUrl + "\"";

    // 服务接口名称， 固定值
    orderInfo += "&service=\"mobile.securitypay.pay\"";

    // 支付类型， 固定值
    orderInfo += "&payment_type=\"1\"";

    // 参数编码， 固定值
    orderInfo += "&_input_charset=\"utf-8\"";

    // 设置未付款交易的超时时间
    // 默认30分钟，一旦超时，该笔交易就会自动被关闭。
    // 取值范围：1m～15d。
    // m-分钟，h-小时，d-天，1c-当天（无论交易何时创建，都在0点关闭）。
    // 该参数数值不接受小数点，如1.5h，可转换为90m。
    orderInfo += "&it_b_pay=\"60m\"";

    // extern_token为经过快登授权获取到的alipay_open_id,带上此参数用户将使用授权的账户进行支付
    // orderInfo += "&extern_token=" + "\"" + extern_token + "\"";

    // 支付宝处理完请求后，当前页面跳转到商户指定页面的路径，可空
    //orderInfo += "&return_url=\"\"";

    // 调用银行卡支付，需配置此参数，参与签名， 固定值 （需要签约《无线银行卡快捷支付》才能使用）
    // orderInfo += "&paymethod=\"expressGateway\"";

    return orderInfo;
  }
}
