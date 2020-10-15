//: [Previous](@previous)

import Foundation
import Combine
import UIKit

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

example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 2 {
            isReady.send()
        }
    }
}

example(of: "Challenge") {
    let numbers = (1...100).publisher
    numbers.dropFirst(50)
        .prefix(20)
        .filter({ $0%2 == 0 })
        .sink(receiveCompletion: { print("Completed with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Output...)") {
    let publisher = [3, 4].publisher
    publisher
        .prepend(1, 2)
        .prepend(-1, 0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Sequence)") {
    let publisher = stride(from: 6, to: 11, by: 2).publisher
    publisher
        .prepend(5,6,7)
        .prepend([3, 4])
        .prepend(Set(1...2))
        .prepend(0)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher)") {
    let publisher1 = [3, 4].publisher
    let publisher2 = [1, 2].publisher
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "prepend(Publisher) #2") {
    let publisher1 = [3, 4].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher1
        .prepend(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

example(of: "append(Output...)") {
    let publisher = [1].publisher
    publisher
        .append(2, 3)
        .append(4)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Output...) #2") {
    let publisher = PassthroughSubject<Int, Never>()
    publisher
        .append(3, 4)
        .append(5)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
}

example(of: "append(Sequence)") {
    let publisher = [1, 2, 3].publisher
    publisher
        .append([4, 5]) // 2
        .append(Set([6, 7])) // 3
        .append(stride(from: 8, to: 11, by: 2))
        .append(11)// 4
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "append(Publisher)") {
    let publisher1 = [1, 2].publisher
    let publisher2 = [3, 4].publisher
    publisher1
        .append(publisher2)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "switchToLatest") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    
    let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    publishers
        .switchToLatest()
        .sink(receiveCompletion: { _ in print("Completed!") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    publishers.send(publisher1)
    publisher1.send(1)
    publisher1.send(2)
    
    publishers.send(publisher2)
    publisher1.send(3)
    publisher2.send(4)
    publisher2.send(5)
    
    publishers.send(publisher3)
    publisher2.send(6)
    publisher3.send(7)
    publisher3.send(8)
    publisher3.send(9)
    
    publisher3.send(completion: .finished)
    publishers.send(completion: .finished)
}

var subscription: AnyCancellable?
/*
 example(of: "switchToLatest - Network Request") {
 let url = URL(string: "https://source.unsplash.com/random")!
 
 func getImage() -> AnyPublisher<UIImage?, Never> {
 return URLSession
 .shared
 .dataTaskPublisher(for: url)
 .map { data, _ in UIImage(data: data) }
 .print("image1")
 .replaceError(with: nil)
 .eraseToAnyPublisher()
 }
 
 let taps = PassthroughSubject<Void, Never>()
 
 subscription = taps
 .map { _ in getImage() }
 .switchToLatest()
 .sink(receiveValue: { print($0) })
 taps.send()
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
 taps.send()
 }
 DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
 taps.send()
 }
 }
 */

example(of: "merge(with:)") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()
    let publisher3 = PassthroughSubject<Int, Never>()
    
    publisher1
        .merge(with: publisher2).merge(with: publisher3)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    publisher3.send(1)
    
    publisher1.send(6)
    publisher1.send(2)
    
    publisher2.send(3)
    
    publisher1.send(4)
    
    publisher2.send(5)
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
    publisher3.send(completion: .finished)
    
}

example(of: "combineLatest") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    publisher1
        .combineLatest(publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    
    publisher2.send("a")
    publisher2.send("b")
    
    publisher1.send(3)
    publisher2.send("c")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

example(of: "zip") {
    
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()
    
    publisher1
        .zip(publisher2)
        .sink(receiveCompletion: { _ in print("Completed") },
              receiveValue: { print("P1: \($0), P2: \($1)") })
        .store(in: &subscriptions)
    
    publisher1.send(1)
    publisher1.send(2)
    publisher2.send("a")
    publisher2.send("b")
    publisher1.send(3)
    publisher2.send("c")
    publisher2.send("d")
    
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}
