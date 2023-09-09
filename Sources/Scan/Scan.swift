//
//  Scan.swift
//  Scan
//
//  Created by Adam Roberts on 12/9/19.
//  Modified to compile with current Swift from 
//  Apple's Swift documentation in LazySequence.swift
//

public extension Sequence {
  /// Returns an array containing the results of
  ///
  ///   p.reduce(initial, nextPartialResult)
  ///
  /// for each prefix `p` of `self`, in order from shortest to
  /// longest.  For example:
  ///
  ///     (1..<6).scan(0, +) // [0, 1, 3, 6, 10, 15]
  ///
  /// - Complexity: O(n)
  @inlinable
  func scan<ResultElement>(
    _ initial: ResultElement,
    _ nextPartialResult: (ResultElement, Element) -> ResultElement
  ) -> [ResultElement] {
    var result = [initial]
    for x in self {
      result.append(nextPartialResult(result.last!, x))
    }
    return result
  }
}

public extension LazySequenceProtocol {
  /// Returns a sequence containing the results of
  ///
  ///   p.reduce(initial, nextPartialResult)
  ///
  /// for each prefix `p` of `self`, in order from shortest to
  /// longest.  For example:
  ///
  ///     Array((1...).lazy.scan(0, +).prefix(6)) // [0, 1, 3, 6, 10, 15]
  ///
  /// - Complexity: O(1)
  @inlinable
  func scan<ResultElement>(
    _ initial: ResultElement,
    _ nextPartialResult: @escaping (ResultElement, Element) -> ResultElement
  ) -> LazyScanSequence<Self, ResultElement> {
    return LazyScanSequence(
        initial: initial, base: self, nextPartialResult: nextPartialResult)
  }
}

public struct LazyScanSequence<Base: Sequence, ResultElement>
  : LazySequenceProtocol // Chained operations on self are lazy, too
{
  @inlinable
  public func makeIterator() -> LazyScanIterator<Base.Iterator, ResultElement> {
    return LazyScanIterator(
        nextElement: initial, base: base.makeIterator(), nextPartialResult: nextPartialResult)
  }
  @inlinable
  internal init(initial: ResultElement, base: Base, nextPartialResult: @escaping (ResultElement, Base.Element) -> ResultElement) {
    self.initial = initial
    self.base = base
    self.nextPartialResult = nextPartialResult
  }
  @usableFromInline
  internal let initial: ResultElement
  @usableFromInline
  internal let base: Base
  @usableFromInline
  internal let nextPartialResult:
    (ResultElement, Base.Element) -> ResultElement
}

public struct LazyScanIterator<Base : IteratorProtocol, ResultElement>
  : IteratorProtocol {
  @inlinable
  mutating public func next() -> ResultElement? {
    if first {
        first = false
        return nextElement               // if first time pass through initial value
    }
    guard let prev = nextElement else { return nil }
    guard let baseNext = base.next() else { return nil }
    nextElement = nextPartialResult(prev,baseNext)
    return nextElement
  }
  @inlinable
  internal init(nextElement: ResultElement?, base: Base, nextPartialResult: @escaping (ResultElement, Base.Element) -> ResultElement) {
    self.nextElement = nextElement
    self.base = base
    self.nextPartialResult = nextPartialResult
  }
  @usableFromInline
  internal var first: Bool = true          // In first iteration we pass through initial value
  @usableFromInline
  internal var nextElement: ResultElement? // The next result of next().
  @usableFromInline
  internal var base: Base                  // The underlying iterator.
  @usableFromInline
  internal let nextPartialResult: (ResultElement, Base.Element) -> ResultElement
}

