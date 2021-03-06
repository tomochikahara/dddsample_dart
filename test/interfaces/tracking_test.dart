import 'package:unittest/unittest.dart';
import 'package:intl/intl.dart';

import 'package:dddsample/interfaces/tracking.dart';

import 'package:dddsample/cargo.dart';
import "package:dddsample/handling.dart";

import "../sample/sample_location.dart";
import "../sample/sample_voyage.dart";

main() => run();

run() {

  DateTime date(int millisecondsSinceEpoch) =>
      new DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch, isUtc:true);

  group("CargoTrackingViewadapter", () {
    
    test("create", () {
      var cargo = new Cargo(new TrackingId("XYZ"), new RouteSpecification(HANGZOU, HELSINKI, new DateTime.now()));
      
      var events = new List<HandlingEvent>();
      events.add(new HandlingEvent(cargo, date(1), date(2), HandlingEventType.RECEIVE, HANGZOU));
      
      events.add(new HandlingEvent(cargo, date(3), date(4), HandlingEventType.LOAD, HANGZOU, CM001));
      events.add(new HandlingEvent(cargo, date(5), date(6), HandlingEventType.UNLOAD, HELSINKI, CM001));
      
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      var adapter = new CargoTrackingViewAdapter(cargo, events);
      
      expect(adapter.trackingId, equals("XYZ"));
      expect(adapter.origin, equals("Hangzhou"));
      expect(adapter.destination, equals("Helsinki"));
      expect(adapter.statusText, equals("In port Helsinki"));
      
      var iter = adapter.events.iterator;
      
      iter.moveNext();
      HandlingEventViewAdapter event = iter.current;
      expect(event.type, equals("RECEIVE"));
      expect(event.location, equals("Hangzhou"));
      expect(event.time, equals("1970-01-01 00:00"));
      expect(event.voyageNumber, equals(""));
      expect(event.isExpected, isTrue);
      
      iter.moveNext();
      event = iter.current;
      expect(event.type, equals("LOAD"));
      expect(event.location, equals("Hangzhou"));
      expect(event.time, equals("1970-01-01 00:00"));
      expect(event.voyageNumber, equals("CM001"));
      expect(event.isExpected, isTrue);
      
      iter.moveNext();
      event = iter.current;
      expect(event.type, equals("UNLOAD"));
      expect(event.location, equals("Helsinki"));
      expect(event.time, equals("1970-01-01 00:00"));
      expect(event.voyageNumber, equals("CM001"));
      expect(event.isExpected, isTrue);
    });
  });
}