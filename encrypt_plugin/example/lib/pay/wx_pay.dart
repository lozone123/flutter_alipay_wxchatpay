import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:encrypt_plugin_example/pay/ip_helper.dart';
import 'package:encrypt_plugin_example/pay/order_info_util.dart';
import 'package:encrypt_plugin_example/pay/wxpay_config.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

class WxPay {
  //生成预付订单号
  static Future<String> _getPreOrderNo(
      String body, String orderNo, String price, String nonStr) async {
    String ip = await IPHelper.getLocalIp();
    Map<String, String> _paramsMap = new Map();
    _paramsMap.putIfAbsent("appid", () => WxPayConfig.APPID);
    _paramsMap.putIfAbsent("mch_id", () => WxPayConfig.mch_id);
    _paramsMap.putIfAbsent("nonce_str", () => nonStr);
    _paramsMap.putIfAbsent("body", () => body);
    _paramsMap.putIfAbsent("out_trade_no", () => orderNo);
    _paramsMap.putIfAbsent("total_fee", () => price); //fen
    _paramsMap.putIfAbsent("spbill_create_ip", () => ip); //user ip
    _paramsMap.putIfAbsent("notify_url", () => WxPayConfig.notifyUrl);
    _paramsMap.putIfAbsent("trade_type", () => WxPayConfig.trade_type);
    //sign
    String orderInfoStr =
        OrderInfoUtil.buildOrderParamAndSort(_paramsMap, false);

    orderInfoStr += "&key=${WxPayConfig.Md5Key}";

    String signStr = sign(orderInfoStr);
    _paramsMap.putIfAbsent("sign", () => signStr.toUpperCase());
    String paramXml = createXml(_paramsMap);
    var dio = Dio();
    var res = await dio.post<String>(WxPayConfig.payUrl, data: paramXml);
    print(res);
    return res.data;
  }

  static String sign(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return digest.toString();
    //return hex.encode(digest.bytes);
  }

  static String createXml(Map<String, String> map) {
    var iters = map.entries.iterator;
    String paramXml = "<xml>";
    while (iters.moveNext()) {
      var entry = iters.current;
      paramXml += "<${entry.key}>${entry.value}</${entry.key}>";
    }
    paramXml += "</xml>";
    return paramXml;
  }

  static Future<dynamic> doPay(
      String body, String orderNo, String price) async {
    var uuid = Uuid();
    var nonStr = uuid.v4().replaceAll("-", "");
    var preOrderNoResult = await _getPreOrderNo(body, orderNo, price, nonStr);

    //匹配prepay_id
    RegExp regExp =
        RegExp("<prepay_id><\\!\\[CDATA\\[(.*?)\\]\\]></prepay_id>");
    //匹配nonstr
    RegExp regExpNonStr =
        RegExp("<nonce_str><\\!\\[CDATA\\[(.*?)\\]\\]></nonce_str>");
    //配置sign字符串
    RegExp regExpSign = RegExp("<sign><\\!\\[CDATA\\[(.*?)\\]\\]></sign>");

    var match = regExp.firstMatch(preOrderNoResult);
    var preOrderNo = "";
    if (match != null && match.groupCount > 0) {
      preOrderNo = match.group(1);
    } else {
      return "";
    }
    print(preOrderNo);

    match = regExpNonStr.firstMatch(preOrderNoResult);
    if (match != null && match.groupCount > 0) {
      nonStr = match.group(1);
    } else {
      return "";
    }

    print(nonStr);

    var signStr = "";
    match = regExpSign.firstMatch(preOrderNoResult);
    if (match != null && match.groupCount > 0) {
      signStr = match.group(1);
    } else {
      return "";
    }
    print(signStr);
    print((DateTime.now().microsecondsSinceEpoch ~/ 1000).toString());
    var map = Map();
    map.putIfAbsent("prepayId", () => preOrderNo);
    map.putIfAbsent("nonceStr", () => nonStr);
    map.putIfAbsent("sign", () => signStr);
    map.putIfAbsent("timeStamp",
        () => (DateTime.now().microsecondsSinceEpoch ~/ 1000).toString());
    return map;
  }
}
