abstract class ValueObject {
  const ValueObject();

  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ValueObject) return false;
    
    return other.props.toString() == props.toString(); 
  }

  @override
  int get hashCode => props.toString().hashCode;
}