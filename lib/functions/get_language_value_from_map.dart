
import 'package:foodika/core/services/language_service.dart';
import 'package:get/get.dart';

String getLanguageValue(Map<String, String> map) {
  String str = '';
  var languageCode = Get.find<LanguageService>().locale.languageCode;
  if (map.containsKey(languageCode)) {
    str = map[languageCode]!;
  } else if (map.containsKey('en')) {
    str = map['en']!;
  } else if (map.entries.isEmpty) {
    str = 'Unknown'.tr;
  } else {
    str = map.entries.first.value;
  }

  return str
      .replaceAll('žurnāls ', '')
      .replaceAll(
        'žurnāls '.toUpperCase(),
        '',
      )
      .replaceAll('žurn ', '')
      .replaceAll('žurn '.toLowerCase(), '');
}
