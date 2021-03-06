part of domain.cargo;

/**
 * Uniquely identifies a particular cargo.
 * Automaticaly generated by the application.
 */
class TrackingId implements ValueObject<TrackingId>{
  final String _id;

  const TrackingId._(this._id);
  
  factory TrackingId(String id) {
    if (id == null) throw new ArgumentError("id must not be null.");
    return new TrackingId._(id);
  }
  
  bool sameValueAs(TrackingId other) => other != null && _id == other._id;
  
  String get idString => _id;
  
  int get hashCode => _id.hashCode;

  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other == null || other is! TrackingId) return false;
    return sameValueAs(other as TrackingId);
  }

  String toString() => _id;
}
