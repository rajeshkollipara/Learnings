//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI
import PlaygroundSupport
import UIKit

var str = "Hello, playground"
print(str)
//: [Next](@next)
/*
let valuesPerSecond = 1.0
let delayInSeconds = 1.5

let sourcePublisher = PassthroughSubject<Date, Never>()

let delayedPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)

let subscription = Timer
    .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
    .autoconnect()
    .subscribe(sourcePublisher)

let sourceTimeline = TimelineView(title: "Emitted values (\(valuesPerSecond) per sec.):")


let delayedTimeline = TimelineView(title: "Delayed values (with a \(delayInSeconds)s delay):")

let view = VStack(spacing: 50) {
    sourceTimeline
    delayedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)
sourcePublisher.displayEvents(in: sourceTimeline)
delayedPublisher.displayEvents(in: delayedTimeline)
*/

let valuesPerSecond = 1.0
let collectTimeStride = 4
let collectMaxCount = 2

let sourcePublisher = PassthroughSubject<Date, Never>()

let collectedPublisher = sourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride))).flatMap { dates in dates.publisher }
let collectedPublisher2 = sourcePublisher
  .collect(.byTimeOrCount(DispatchQueue.main,
                          .seconds(collectTimeStride),
                          collectMaxCount))
  .flatMap { dates in dates.publisher }
let subscription = Timer
  .publish(every: 1.0 / valuesPerSecond, on: .main, in: .common)
  .autoconnect()
  .subscribe(sourcePublisher)
let sourceTimeline = TimelineView(title: "Emitted values:")
let collectedTimeline = TimelineView(title: "Collected values (every \(collectTimeStride)s):")
let collectedTimeline2 = TimelineView(title: "Collected values (at most \(collectMaxCount) every \(collectTimeStride)s):")
let view = VStack(spacing: 40) {
  sourceTimeline
  collectedTimeline
    collectedTimeline2
}.frame(width: 450, height: 500, alignment: .center)
PlaygroundPage.current.liveView = UIHostingController(rootView: view)
sourcePublisher.displayEvents(in: sourceTimeline)
collectedPublisher.displayEvents(in: collectedTimeline)
collectedPublisher2.displayEvents(in: collectedTimeline2)
