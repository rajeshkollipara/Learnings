/*:
 ### Table Of Contents
 
 1. [Introduction](Introduction)
 2. [Publishers](Publishers)
 */


import UIKit
import Combine

public func example(of description: String,
                    action: () -> Void) {
    print("\n------------------------\(description)----------------------------------\n")
    action()
    
}

example(of: "Inbuilt Publishers 1") {
    let arrayPublisher = [1,2,3,4,5].publisher
    print(type(of: arrayPublisher))
    
    
    arrayPublisher.sink { (_) in
        print("Completion called")
    } receiveValue: { (value) in
        print("Value is : \(value)")
    }
    
}

example(of: "Inbuilt Publishers 2") {
    
    
    let myNotification = Notification.Name("MyNotification")
    let notificationPublisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil).eraseToAnyPublisher()
    
    print(type(of: notificationPublisher))
    
    let subscription = notificationPublisher.sink { (_) in
        print("Subscription Completed")
        
    } receiveValue: { (notification) in
        print("Notification received from publisher : \(String(describing: notification.object))")
        
    }
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: "MyNotification"), object: 5, userInfo: nil)
    NotificationCenter.default.post(name: Notification.Name(rawValue: "MyNotification"), object: 15, userInfo: nil)
    subscription.cancel()
    NotificationCenter.default.post(name: Notification.Name(rawValue: "MyNotification"), object: 20, userInfo: nil)
    
    
}

example(of: "Just Publisher with Sink Subscriber") {
    let just = Just("Hello world!")
    
    let subscriber1 = just
        .sink(
            receiveCompletion: {
                print("Received completion", $0)
            },
            receiveValue: {
                print("Received value", $0)
            })
    
    let subscriber2 = just
        .sink(
            receiveCompletion: {
                print("Received completion (another)", $0)
            },
            receiveValue: {
                print("Received value (another)", $0)
            })
    
}

example(of: "Example of assign(to:on:) subscriber") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    let publisher = ["Hello", "world!", "Rajesh"].publisher
    _ = publisher
        .assign(to: \.value, on: object)
}

example(of: "Custom Subscriber") {
    
    let publisher = (1...6).publisher
    
    final class IntSubscriber: Subscriber {
        
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            //Setting number of values Subscriber can receive. It doesnt matter how many values publisher sends Subscriber will receive only given number of values from the below line.
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value: \(input)")
            //incrementing demand after receiving input value.
            return .max(2)
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion, \(completion)")
        }
        
    }
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
    
}

var subscriptions = Set<AnyCancellable>()

example(of: "Future") {
    func futureIncrement(
        integer: Int,
        afterDelay delay: TimeInterval) -> Future<Int, Never> {
        
        Future<Int, Never> { promise in
            print("Original")
            
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                promise(.success(integer + 1))
            }
        }
        
    }
    let future = futureIncrement(integer: 1, afterDelay: 3)
    
    future
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    future
        .sink(receiveCompletion: { print("Second", $0) },
              receiveValue: { print("Second", $0) })
        .store(in: &subscriptions)
    
}

example(of: "PassthroughSubject") {
    enum MyError: Error {
        case test
    }
    
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            //Now total capacity of this subscriber to receive values is 2 (set in previous function) + 2 (set in this function). So total of 4
            return input == "World" ? .max(2): .none
            
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }
    }
    
    let subscription1 = StringSubscriber()
    let subject = PassthroughSubject<String, MyError>()
    subject.subscribe(subscription1)
    let subscription2 = subject
        .sink(
            receiveCompletion: { completion in
                print("Received completion (sink)", completion)
            },
            receiveValue: { value in
                print("Received value (sink)", value)
            }
        )
    
    subject.send("Hello")
    subject.send("World")
    subject.send("Rajesh")
    subject.send("Suresh")
    subject.send("Mahesh")
    subscription2.cancel()
    subject.send("There?")
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")
    
}

example(of: "CurrentValueSubject") {
    
    var subscriptions = Set<AnyCancellable>()
    let subject = CurrentValueSubject<Int, Never>(0)
    
    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    subject.send(1)
    print(subject.value)
    subject.send(2)
    print(subject.value)
    subject.value = 3
    print(subject.value)
    subject.send(completion: .finished)
    
}


example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            
            switch input {
            
            case 1:
                return .max(2) // 1
            case 3:
                return .max(1) // 2
            default:
                return .none // 3
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

example(of: "Type erasure") {
    let subject = PassthroughSubject<Int, Never>()
    let publisher = subject.eraseToAnyPublisher()
    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    subject.send(0)
    // publisher.send(1)
    //The above line is not accepted because we Type erased Publisher
}
