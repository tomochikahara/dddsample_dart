part of handling;

class HandlingEvent implements DomainEvent<HandlingEvent> {
  
  final Cargo cargo;
  final Date completionTime;
  final Date registrationTime;
  final HandlingEventType type;
  final Location location;
  final Voyage voyage;
  
  HandlingEvent._(this.cargo, this.completionTime, this.registrationTime,
      this.type, this.location, this.voyage);
  
  factory HandlingEvent(Cargo cargo, Date completionTime, Date registrationTime,
      HandlingEventType type, Location location, [Voyage voyage = Voyage.NONE]) {
    Expect.isNotNull(cargo, "Cargo is required");
    Expect.isNotNull(completionTime, "Completion time is required");
    Expect.isNotNull(registrationTime, "Registration time is required");
    Expect.isNotNull(type, "Handling Event type is required");
    Expect.isNotNull(location, "Location is required");

    if (?voyage) {
      Expect.isNotNull(voyage, "Voyage is required");
      if (type.prohibitsVoyage) throw new ArgumentError("Voyage is not allowed with event type $type");
    } else {
      if (type.requiresVoyage) throw new ArgumentError("Voyage is required for event type $type");
    }
    
    return new HandlingEvent._(cargo, completionTime, registrationTime, type, location, voyage);
  }
  
  bool sameEventAs(HandlingEvent other) =>
    other != null && 
    cargo == other.cargo &&
    voyage == other.voyage &&
    completionTime == other.completionTime &&
    location == other.location &&
    type == other.type;
  
  int get hashCode {
    const int constant = 37;
    return
      [cargo, completionTime, registrationTime, type, location, voyage]
        .reduce(17, (total, elem) => elem == null ? total : total * constant + elem.hashCode);
  }
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! HandlingEvent) return false;
    return sameEventAs(other as HandlingEvent);
  }
  
  String toString() {
    
    String text = """
--- Handling event ---
Cargo: ${cargo.trackingId}
Type: ${type}
Location: ${location.name}
Completed on: ${completionTime}
Registered on: ${registrationTime}
    """;
    
    var sb = new StringBuffer(text);
    if (voyage != Voyage.NONE) {
      sb.add("Voyage: ${voyage.voyageNumber}");
    }
    return sb.toString();
  }
}

class HandlingEventType implements ValueObject<HandlingEventType> {
  
  static const LOAD = const HandlingEventType._(0, true);
  static const UNLOAD = const HandlingEventType._(1, true);
  static const RECEIVE = const HandlingEventType._(2, false);
  static const CLAIM = const HandlingEventType._(3, false);
  static const CUSTOMS = const HandlingEventType._(4, false);
  
  final num _value;
  final bool requiresVoyage;
  
  const HandlingEventType._(this._value, this.requiresVoyage);
  
  bool get prohibitsVoyage => !requiresVoyage;
  
  bool sameValueAs(HandlingEventType other) {
    return _value == other._value;
  }
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! HandlingEventType) return false;
    return sameValueAs(other as HandlingEventType);
  }
}

class HandlingEventFactory {
  
  final CargoRepository _cargoRepos;
  final VoyageRepository _voyageRepos;
  final LocationRepository _locationRepos;
  
  HandlingEventFactory(this._cargoRepos, this._voyageRepos, this._locationRepos);
  
  HandlingEvent createHandlingEvent(
    Date registrationTime, Date completionTime,
    TrackingId trackingId, VoyageNumber voyageNumber,
    UnLocode unLocode, HandlingEventType type) {
    
    var cargo = _findCargo(trackingId);
    var voyage = _findVoyage(voyageNumber);
    var location = _findLocation(unLocode);
    
    try {
      if (voyage == null) {
        return new HandlingEvent(cargo, completionTime, registrationTime, type, location);
      } else {
        return new HandlingEvent(cargo, completionTime, registrationTime, type, location, voyage);
      }
    } on Exception catch(e) {
      throw new CannotCreateHandlingEventException(e);      
    }
  }

  Cargo _findCargo(TrackingId trackingId) {
    var cargo = _cargoRepos.find(trackingId);
    if (cargo == null) throw new UnknownCargoException(trackingId);
    return cargo;
  }
  
  Voyage _findVoyage(VoyageNumber voyageNumber) {
    if (voyageNumber == null) return null;
    
    var voyage = _voyageRepos.find(voyageNumber);
    if (voyage == null) throw new UnknownVoyageException(voyageNumber);
    return voyage;
  }
  
  Location _findLocation(UnLocode unLocode) {
    var location = _locationRepos.find(unLocode);
    if (location == null) throw new UnknownLocationException(unLocode);
    return location;
  }
}