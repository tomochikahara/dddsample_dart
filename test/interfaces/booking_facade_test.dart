import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';

import 'package:dddsample/interfaces/booking.dart';

import 'package:dddsample/cargo.dart';
import "package:dddsample/handling.dart";
import "package:dddsample/voyage.dart";
import "package:dddsample/location.dart";

import "../sample/sample_location.dart";
import "../sample/sample_voyage.dart";

main() => run();

run(){
  
  group("CargoRoutingDtoAssembler", () {
    
    test("to DTO", () {
      var assembler = new CargoRoutingDtoAssembler();
      
      var origin = STOCKHOLM;
      var destination = MELBOURNE;
      var cargo = new Cargo(
                    new TrackingId("XYZ"),
                    new RouteSpecification(origin, destination, new DateTime.now()));
      
      var itinerary = new Itinerary.withLegs([
        new Leg(CM001, origin, SHANGHAI, new DateTime.now(), new DateTime.now()),
        new Leg(CM001, ROTTERDAM, destination, new DateTime.now(), new DateTime.now())
      ]);
      
      cargo.assignToRoute(itinerary);
      
      var dto = assembler.toDto(cargo);
      
      expect(dto.legs.length, equals(2));
      
      var legDto = dto.legs[0];
      expect(legDto.voyageNumber, equals("CM001"));
      expect(legDto.from, equals("SESTO"));
      expect(legDto.to, equals("CNSHA"));
      
      legDto = dto.legs[1];
      expect(legDto.voyageNumber, equals("CM001"));
      expect(legDto.from, equals("NLRTM"));
      expect(legDto.to, equals("AUMEL"));
    });
    
    test("to Dto : No Itinerary", () {
      var assembler = new CargoRoutingDtoAssembler();
      
      var cargo = new Cargo(
                    new TrackingId("XYZ"),
                    new RouteSpecification(STOCKHOLM, MELBOURNE, new DateTime.now()));
      var dto = assembler.toDto(cargo);
      
      expect(dto.trackingId, equals("XYZ"));
      expect(dto.origin, equals("SESTO"));
      expect(dto.finalDestination, equals("AUMEL"));
      expect(dto.legs.isEmpty, isTrue);
    });
  });
  
  group("ItineraryCandidateDtoAssembler", () {
    
    test("to DTO", () {
      var assembler = new ItineraryCandidateDtoAssembler();
      
      var origin = STOCKHOLM;
      var destination = MELBOURNE;
      
      var itinerary = new Itinerary.withLegs([
        new Leg(CM001, origin, SHANGHAI, new DateTime.now(), new DateTime.now()),
        new Leg(CM001, ROTTERDAM, destination, new DateTime.now(), new DateTime.now())
      ]);
      
      var dto = assembler.toDto(itinerary);
      
      expect(dto.legs.length, equals(2));
      
      var legDto = dto.legs[0];
      expect(legDto.voyageNumber, equals("CM001"));
      expect(legDto.from, equals("SESTO"));
      expect(legDto.to, equals("CNSHA"));
      
      legDto = dto.legs[1];
      expect(legDto.voyageNumber, equals("CM001"));
      expect(legDto.from, equals("NLRTM"));
      expect(legDto.to, equals("AUMEL"));
    });
    
    test("from DTO", () {
      var assembler = new ItineraryCandidateDtoAssembler();
      
      var legs = <LegDto>[
        new LegDto("CM001", "AAAAA", "BBBBB", new DateTime.now(), new DateTime.now()),
        new LegDto("CM001", "BBBBB", "CCCCC", new DateTime.now(), new DateTime.now())
      ];
      
      var locationRepos = new LocationReposMock();
      locationRepos.when(callsTo("find", new UnLocode("AAAAA"))).thenReturn(HONGKONG);
      locationRepos.when(callsTo("find", new UnLocode("BBBBB"))).thenReturn(TOKYO, 2);
      locationRepos.when(callsTo("find", new UnLocode("CCCCC"))).thenReturn(CHICAGO);
      
      var voyageRepos = new VoyageRepositoryInMem();
      
      var itinerary = assembler.fromDto(
                        new RouteCandidateDto(legs), voyageRepos, locationRepos);
      
      expect(itinerary, isNotNull);
      expect(itinerary.legs, isNotNull);
      expect(itinerary.legs.length, equals(2));
      
      var leg1 = itinerary.legs[0];
      expect(leg1, isNotNull);
      expect(leg1.loadLocation, equals(HONGKONG));
      expect(leg1.unloadLocation, equals(TOKYO));
      
      var leg2 = itinerary.legs[1];
      expect(leg2, isNotNull);
      expect(leg2.loadLocation, equals(TOKYO));
      expect(leg2.unloadLocation, equals(CHICAGO));
    });
  });
  
  group("LocationDtoAssembler", () {
    
    test("to Dto list", () {
      var assembler = new LocationDtoAssembler();
      
      var locationList = [STOCKHOLM, HAMBURG];
      var dtos = assembler.toDtoList(locationList);
      
      expect(dtos.length, equals(2));
      
      var dto = dtos[0];
      expect(dto.unLocode, equals("SESTO"));
      expect(dto.name, equals("Stockholm"));
      
      dto = dtos[1];
      expect(dto.unLocode, equals("DEHAM"));
      expect(dto.name, equals("Hamburg"));
    });
  });
}

class LocationReposMock extends Mock implements LocationRepository {}

class VoyageRepositoryInMem implements VoyageRepository {
  Voyage find(VoyageNumber voyageNumber) => lookupVoyage(voyageNumber);
}