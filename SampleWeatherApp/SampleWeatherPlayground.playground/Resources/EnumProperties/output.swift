extension Validated {

  var valid: Valid? {
    guard case let .valid(value) = self else { return nil }
    return value
  }

  var isValid: Bool {
    return self.valid != nil
  }

  var invalid: [Invalid]? {
    guard case let .invalid(value) = self else { return nil }
    return value
  }

  var isInvalid: Bool {
    return self.invalid != nil
  }

}

extension Optional {

  var some: A? {
    guard case let .some(value) = self else { return nil }
    return value
  }

  var isSome: Bool {
    return self.some != nil
  }

  var none: Optional? {
    guard case .none = self else { return nil }
    return self
  }

  var isNone: Bool {
    return self.none != nil
  }

}

extension Multiple {

  var zero: Multiple? {
    guard case .zero = self else { return nil }
    return self
  }

  var isZero: Bool {
    return self.zero != nil
  }

  var one: A? {
    guard case let .one(value) = self else { return nil }
    return value
  }

  var isOne: Bool {
    return self.one != nil
  }

  var two: (B, A)? {
    guard case let .two(value) = self else { return nil }
    return value
  }

  var isTwo: Bool {
    return self.two != nil
  }

  var three: (C, A, B)? {
    guard case let .three(value) = self else { return nil }
    return value
  }

  var isThree: Bool {
    return self.three != nil
  }

}

extension Node {

  var el: (tag: String, attributes: [String: String], children: [Node])? {
    guard case let .el(value) = self else { return nil }
    return value
  }

  var isEl: Bool {
    return self.el != nil
  }

  var text: String? {
    guard case let .text(value) = self else { return nil }
    return value
  }

  var isText: Bool {
    return self.text != nil
  }

}

extension Node2 {

  var el: [Node]? {
    guard case let .el(value) = self else { return nil }
    return value
  }

  var isEl: Bool {
    return self.el != nil
  }

  var text: String? {
    guard case let .text(value) = self else { return nil }
    return value
  }

  var isText: Bool {
    return self.text != nil
  }

}


