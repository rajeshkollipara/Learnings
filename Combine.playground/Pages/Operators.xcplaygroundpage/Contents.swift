//: [Previous](@previous)

import Foundation
import Combine

public func example(of description: String,
                    action: () -> Void) {
    print("\n------------------------\(description)----------------------------------\n")
    action()
    
}

var subscriptions = Set<AnyCancellable>()
example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher.collect()
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    ["A", "B", "C", "D", "E"].publisher.collect(2)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "map") {
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2
    [1223, 4, 56].publisher
        // 3
        .map {
            formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "map key paths") {
    let publisher = PassthroughSubject<Coordinate, Never>()
    publisher
        .map(\.x, \.y)
        .sink(receiveValue: { x, y in
            print(
                "The coordinate at (\(x), \(y)) is in quadrant",
                quadrantOf(x: x, y: y)
            )
        })
        .store(in: &subscriptions)
    
    publisher.send(Coordinate(x: 10, y: -8))
}

example(of: "tryMap") {
    // 1
    Just("Directory name that does not exist")
        // 2
        .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
        // 3
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}
