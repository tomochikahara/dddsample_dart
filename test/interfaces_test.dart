import 'package:unittest/unittest.dart';

import 'package:dddsample/domain.dart';
import 'package:dddsample/application/service.dart';

import 'interfaces/booking_facade_test.dart' as booking_facade_test;
import 'interfaces/tracking_test.dart' as tracking_test;

main() => run();

run() {
  booking_facade_test.run();
  tracking_test.run();
}