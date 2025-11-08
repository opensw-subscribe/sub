import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // 로그 줄에서 호출 위치 안보이게
  ),
);
