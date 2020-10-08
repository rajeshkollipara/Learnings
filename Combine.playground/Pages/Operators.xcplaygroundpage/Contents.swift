//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()
//Transform Operators
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

example(of: "flatMap") {
    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
    let james = Chatter(name: "James", message: "Hi, I'm James!")
    let chat = CurrentValueSubject<Chatter, Never>(charlotte)
    //    chat
    //        .sink(receiveValue: { print($0.message.value) })
    //        .store(in: &subscriptions)
    //    charlotte.message.value = "Hi again"
    //    chat.value = james
    
    chat
        .flatMap(maxPublishers: .max(2)) { $0.message }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    charlotte.message.value = "Hi again"
    chat.value = james
    james.message.value = "James: Doing great. You?"
    charlotte.message.value = "Charlotte again"
    
    let morgan = Chatter(name: "Morgan",
                         message: "Hey guys, what are you up to?")
    chat.value = morgan
    charlotte.message.value = "Hi again again"
}

example(of: "replaceNil") {
    ["A", nil, "C"].publisher
        .replaceNil(with: "-")
        .map{ $0! }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    
    let empty = Empty<Int, Never>()
    empty.replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "scan") {
    var dailyGainLoss: Int { .random(in: -10...10) }
    let august2019 = (0..<22)
        .map { _ in dailyGainLoss }
    let tempPublisher =     august2019.publisher
    tempPublisher
        .scan(50) { latest, current in
            max(0, latest + current)
        }
        .sink(receiveValue: { _ in  })
        .store(in: &subscriptions)
}

//Filer Operators
example(of: "filter") {
    let numbers = (1...10).publisher
    numbers
        .filter { $0.isMultiple(of: 2) }
        .sink(receiveValue: { n in
            print("\(n) is a multiple of 2!")
        })
        .store(in: &subscriptions)
}

example(of: "removeDuplicates") {
    let words = "hey hey there! want to listen to mister mister ?"
        .components(separatedBy: " ")
        .publisher
    words
        .removeDuplicates()
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "compactMap") {
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    strings
        .compactMap { Float($0) }
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
    let numbers = (1...10_000).publisher
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "first(where:)") {
    let numbers = (1...9).publisher
    numbers
        .first(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "last(where:)") {
    let numbers = (1...9).publisher
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "last(where:) 2") {
    let numbers = PassthroughSubject<Int, Never>()
    
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)
    
}

example(of: "dropFirst") {
    let numbers = (1...10).publisher
    numbers
        .dropFirst(8)
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    numbers
        .drop(while: {
            print("x")
            return $0 % 5 != 0
        }) .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 3 {
            isReady.send()
        }
    }
}

example(of: "prefix") {
  let numbers = (1...10).publisher
  numbers
    .prefix(2)
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "prefix(while:)") {
  let numbers = (1...10).publisher
  numbers
    .prefix(while: { $0 < 3 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}
