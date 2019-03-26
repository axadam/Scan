//
//  Scan.swift
//  Scan
//
//  Created by Adam Roberts on 12/9/19.
//  Modified to compile with current Swift from 
//  Apple's Swift documentation in LazySequence.swift
//

import Foundation

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
  public func makeIterator() -> LazyScanIterator<Base.Iterator, ResultElement> {
    return LazyScanIterator(
        nextElement: initial, base: base.makeIterator(), nextPartialResult: nextPartialResult)
  }
  fileprivate init(initial: ResultElement, base: Base, nextPartialResult: @escaping (ResultElement, Base.Element) -> ResultElement) {
    self.initial = initial
    self.base = base
    self.nextPartialResult = nextPartialResult
  }
  private let initial: ResultElement
  private let base: Base
  private let nextPartialResult:
    (ResultElement, Base.Element) -> ResultElement
}

public struct LazyScanIterator<Base : IteratorProtocol, ResultElement>
  : IteratorProtocol {
  mutating public func next() -> ResultElement? {
    return nextElement.map { result in
      nextElement = base.next().map { nextPartialResult(result, $0) }
      return result
    }
  }
  fileprivate init(nextElement: ResultElement?, base: Base, nextPartialResult: @escaping (ResultElement, Base.Element) -> ResultElement) {
    self.nextElement = nextElement
    self.base = base
    self.nextPartialResult = nextPartialResult
  }
  private var nextElement: ResultElement? // The next result of next().
  private var base: Base                  // The underlying iterator.
  private let nextPartialResult: (ResultElement, Base.Element) -> ResultElement
}

