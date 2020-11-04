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
/*
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
*/

/*
public let typingHelloWorld: [(TimeInterval, String)] = [
  (0.0, "H"),
  (0.1, "He"),
  (0.2, "Hel"),
  (0.3, "Hell"),
  (0.5, "Hello"),
  (0.6, "Hello "),
  (3.0, "Hello W"),
  (3.1, "Hello Wo"),
  (3.2, "Hello Wor"),
  (3.4, "Hello Worl"),
  (3.5, "Hello World")
]

let subject = PassthroughSubject<String, Never>()
let debounced = subject
    .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
  .share()
let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")

let view = VStack(spacing: 100) {
    subjectTimeline
    debouncedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)

let subscription1 = subject
  .sink { string in
    print("+\(deltaTime)s: Subject emitted: \(string)")
  }

let subscription2 = debounced
  .sink { string in
    print("+\(deltaTime)s: Debounced emitted: \(string)")
  }

subject.feed(with: typingHelloWorld)

*/

public let typingHelloWorld: [(TimeInterval, String)] = [
  (0.0, "H"),
  (0.1, "He"),
  (0.2, "Hel"),
  (0.3, "Hell"),
  (0.5, "Hello"),
  (0.6, "Hello "),
  (1.5, "Hello *"),
  (2.0, "Hello W"),
  (2.1, "Hello Wo"),
  (2.2, "Hello Wor"),
  (2.4, "Hello Worl"),
  (2.5, "Hello World")
]

let throttleDelay = 1.0


let subject = PassthroughSubject<String, Never>()
let throttled = subject
  .throttle(for: .seconds(throttleDelay), scheduler: DispatchQueue.main, latest: true)
    .share()
let subjectTimeline = TimelineView(title: "Emitted values")
let throttledTimeline = TimelineView(title: "Throttled values")

let view = VStack(spacing: 100) {
    subjectTimeline
    throttledTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
throttled.displayEvents(in: throttledTimeline)

let subscription1 = subject
  .sink { string in
    print("+\(deltaTime)s: Subject emitted: \(string)")
  }

let subscription2 = throttled
  .sink { string in
    print("+\(deltaTime)s: Throttled emitted: \(string)")
  }
subject.feed(with: typingHelloWorld)


