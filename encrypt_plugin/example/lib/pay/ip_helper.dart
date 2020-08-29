import 'dart:io';

class IPHelper {
  static Future<String> getLocalIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        print('${addr.address}');
        if (!addr.isLoopback && isIP(addr.address)) {
          return addr.address;
        }
      }
    }
    return "";
  }

  static bool isIP(String addr) {
    if (addr.length < 7 || addr.length > 15 || "" == addr) {
      return false;
    }
    String rexp =
        "([1-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}";

    RegExp exp = new RegExp(rexp);
    return exp.hasMatch(addr);
  }
}
