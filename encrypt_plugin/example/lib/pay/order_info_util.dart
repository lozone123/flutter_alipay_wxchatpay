

import 'dart:convert';

import 'dart:math';

import 'package:encrypt_plugin_example/pay/alipay_config.dart';
import 'package:flutter/cupertino.dart';

/**
 * 2.0 订单串本地签名逻辑
 * 注意：本 Demo 仅作为展示用途，实际项目中不能将 RSA_PRIVATE 和签名逻辑放在客户端进行！
 */
 class OrderInfoUtil {

	/**
	 * 构造授权参数列表
	 *
	 * @param pid
	 * @param app_id
	 * @param target_id
	 * @return
	 */
	//  static Map<String, String> buildAuthInfoMap(String pid, String app_id, String target_id, boolean rsa2) {
	// 	Map<String, String> keyValues = new HashMap<String, String>();

	// 	// 商户签约拿到的app_id，如：2013081700024223
	// 	keyValues.put("app_id", app_id);

	// 	// 商户签约拿到的pid，如：2088102123816631
	// 	keyValues.put("pid", pid);

	// 	// 服务接口名称， 固定值
	// 	keyValues.put("apiname", "com.alipay.account.auth");

	// 	// 服务接口名称， 固定值
	// 	keyValues.put("methodname", "alipay.open.auth.sdk.code.get");

	// 	// 商户类型标识， 固定值
	// 	keyValues.put("app_name", "mc");

	// 	// 业务类型， 固定值
	// 	keyValues.put("biz_type", "openservice");

	// 	// 产品码， 固定值
	// 	keyValues.put("product_id", "APP_FAST_LOGIN");

	// 	// 授权范围， 固定值
	// 	keyValues.put("scope", "kuaijie");

	// 	// 商户唯一标识，如：kkkkk091125
	// 	keyValues.put("target_id", target_id);

	// 	// 授权类型， 固定值
	// 	keyValues.put("auth_type", "AUTHACCOUNT");

	// 	// 签名类型
	// 	keyValues.put("sign_type", rsa2 ? "RSA2" : "RSA");

	// 	return keyValues;
	// }

	/**
	 * 构造支付订单参数列表
	 */
	 static Map<String, String> buildOrderParamMap(String app_id, bool rsa2) {
		Map<String, String> keyValues =Map();
   
		keyValues.putIfAbsent("app_id", ()=>app_id);

		keyValues.putIfAbsent("charset", ()=>"utf-8");

		keyValues.putIfAbsent("method", ()=>"alipay.trade.app.pay");

		keyValues.putIfAbsent("sign_type", ()=>rsa2 ? "RSA2" : "RSA");

		keyValues.putIfAbsent("timestamp", ()=>getTimestamp());

		keyValues.putIfAbsent("version", ()=>"1.0");

		return keyValues;
	}

	static String getTimestamp(){
		DateTime dateTime = DateTime.now();
		var m=dateTime.month<10?"0"+dateTime.month.toString():dateTime.month;
		var d=dateTime.day<10?"0"+dateTime.day.toString():dateTime.day;
		var h=dateTime.hour<10?"0"+dateTime.hour.toString():dateTime.hour;
		var min=dateTime.minute<10?"0"+dateTime.minute.toString():dateTime.minute;
		var s=dateTime.second<10?"0"+dateTime.second.toString():dateTime.second;
		String key =
				"${dateTime.year}-$m-$d $h:$min:$s";
		return key;
	}

	/**
	 * 构造支付订单参数信息
	 *
	 * @param map
	 * 支付订单参数
	 * @return
	 */
	 static String buildOrderParam(Map<String, String> map) {
		List<String> keys = map.keys.toList();
    StringBuffer sb=StringBuffer();

		for (int i = 0; i < keys.length - 1; i++) {
			String key = keys[i];
			String value = map[key];
			sb.write(buildKeyValue(key, value, true));
			sb.write("&");
		}

		String tailKey = keys[keys.length - 1];
		String tailValue = map[tailKey];
		sb.write(buildKeyValue(tailKey, tailValue, true));

		return sb.toString();
	}

	/**
	 * 拼接键值对
	 *
	 * @param key
	 * @param value
	 * @param isEncode
	 * @return
	 */
	 static String buildKeyValue(String key, String value, bool isEncode) {
		StringBuffer sb = new StringBuffer();
		sb.write(key);
		sb.write("=");
   
		if (isEncode) {
			try {
        sb.write(Uri.encodeComponent(value));
				//sb.write(value);
			} catch (UnsupportedEncodingException) {
				sb.write(value);
			}
		} else {
			sb.write(value);
		}
		return sb.toString();
	}

	/**
	 * 对支付参数信息进行签名
	 *
	 * @param map
	 *            待签名授权信息
	 *
	 * @return
	 */
	 static String getSign(Map<String, String> map, String rsaKey, bool rsa2) {
		List<String> keys = map.keys;
		// key排序
	  keys.sort();

		StringBuffer authInfo = new StringBuffer();
		for (int i = 0; i < keys.length - 1; i++) {
			String key = keys[i];
			String value = map[key];
			authInfo.write(buildKeyValue(key, value, false));
			authInfo.write("&");
		}

		String tailKey = keys[keys.length - 1];
		String tailValue = map[tailKey];
		authInfo.write(buildKeyValue(tailKey, tailValue, false));

    return authInfo.toString();

		// String oriSign = SignUtils.sign(authInfo.toString(), rsaKey, rsa2);
		// String encodedSign = "";

		// try {
		// 	encodedSign = URLEncoder.encode(oriSign, "UTF-8");
		// } catch (UnsupportedEncodingException e) {
		// 	e.printStackTrace();
		// }
		// return "sign=" + encodedSign;
	}

  	 static String buildOrderParamAndSort(Map<String, String> map,bool isEncode) {
		List<String> keys = map.keys.toList();
		// key排序
	  keys.sort();

		StringBuffer authInfo = new StringBuffer();
		for (int i = 0; i < keys.length - 1; i++) {
			String key = keys[i];
			String value = map[key];
			authInfo.write(buildKeyValue(key, value, isEncode));
			authInfo.write("&");
		}

		String tailKey = keys[keys.length - 1];
		String tailValue = map[tailKey];
		authInfo.write(buildKeyValue(tailKey, tailValue, isEncode));

    return authInfo.toString();

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
    key = key + r.nextInt(100000).toString();
    print(key);
    key = key.substring(0, 15);
    return key;
	}

}
