part of domain.cargo;

/**
 * A Cargo.
 */
class Cargo implements Entity<Cargo>{

  final TrackingId trackingId;
  
  RouteSpecification routeSpec;
  final Location origin;
  Itinerary _itinerary;
  Delivery delivery;

  Cargo._(this.trackingId, this.routeSpec, this.origin, this.delivery);
  
  factory Cargo(TrackingId trackingId, RouteSpecification routeSpec) {
    if (trackingId == null) throw new ArgumentError("Tracking ID is required.");
    if (trackingId == null) throw new ArgumentError("Route Specification is required.");
    
    Itinerary itinerary = null;
    var delivery = new Delivery.derivedFrom(routeSpec, itinerary, HandlingHistory.EMPTY);
    return new Cargo._(trackingId, routeSpec, routeSpec.origin, delivery);
  }
  
  void specifyNewRoute(RouteSpecification routeSpec) {
    this.routeSpec= routeSpec;
    this.delivery = delivery.updateOnRouting(this.routeSpec, this._itinerary);
  }

  void deriveDeliveryProgress(HandlingHistory handlingHistory) {
    //TODO filter events on cargo (must be same as this cargo
    
    // Delivery is a value object, so we can simply discard the old one
    // and replace it with a new.
    this.delivery = new Delivery.derivedFrom(routeSpec, itinerary, handlingHistory);
  }

  void assignToRoute(Itinerary itinerary) {
    if (itinerary == null) throw new ArgumentError("Itinerary is required for assignment");
    
    this._itinerary = itinerary;
    // Handling consistency within the Cargo aggregate synchronously
    this.delivery = delivery.updateOnRouting(routeSpec, itinerary);
  }
  
  bool sameIdentityAs(Cargo other)
    => other != null && this.trackingId.sameValueAs(other.trackingId);

  Itinerary get itinerary => _itinerary == null ? Itinerary.EMPTY : _itinerary;

  int get hashCode => this.trackingId.hashCode;
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is!Cargo) return false;
    return sameIdentityAs(other as Cargo);
  }
}

abstract class CargoRepository {
  
  Cargo find(TrackingId trackingId);
  
  List<Cargo> findAll();
  
  void store(Cargo cargo);
  
  TrackingId nextTrackingId();
}

//TODO Why no enum?
class TransportStatus implements ValueObject<TransportStatus> {
  
  static const NOT_RECEIVED = const TransportStatus._(0, "NOT_RECEIVED");
  static const IN_PORT = const TransportStatus._(1, "IN_PORT");
  static const ONBOARD_CARRIER = const TransportStatus._(2, "ONBOARD_CARRIER");
  static const CLAIMED = const TransportStatus._(3, "CLAIMED");
  static const UNKNOWN = const TransportStatus._(4, "UNKNOWN");
  
  final num _value;
  final String _name;
  const TransportStatus._(this._value, this._name);
  
  bool sameValueAs(TransportStatus other) => _value == other._value;
  String get name => this._name;
}

class RoutingStatus implements ValueObject<RoutingStatus> {
  
  static const NOT_ROUTED = const RoutingStatus._(0);
  static const ROUTED = const RoutingStatus._(1);
  static const MISROUTED = const RoutingStatus._(2);
  
  final num _value;
  const RoutingStatus._(this._value);
  
  bool sameValueAs(RoutingStatus other) => _value == other._value;
}
