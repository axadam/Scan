# Scan

Scan let's you apply a function to each prefix subsequence of a sequence:

`(1..<6).scan(0, +) // [0, 1, 3, 6, 10, 15]`

A lazy version is also provided:

`Array((1...).lazy.scan(0, +).prefix(6)) // [0, 1, 3, 6, 10, 15]`

This is based directly on comments in Apple's Swift code (LazySequence.swift)
and modified as follows: comply with latest compiler warnings, return the latest
computed result rather than the one from the previous computation.

Swift is Apache licensed: https://swift.org/LICENSE.txt
and this small modification is MIT licensed.

