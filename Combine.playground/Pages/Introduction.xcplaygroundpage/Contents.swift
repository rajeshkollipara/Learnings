/*:
 ### Table Of Contents
 
 1. [Introduction](Introduction)
 2. [Publishers](Publishers)
 */


import UIKit
import Combine

//MARK: Inbuilt publisher
var arrayPublisher = [1,2,3,4,5].publisher
print(type(of: arrayPublisher))


arrayPublisher.sink { (_) in
    print("Completion called")
} receiveValue: { (value) in
    print("Value is : \(value)")
}


let myNotification = Notification.Name("MyNotification")
let notificationPublisher = NotificationCenter.default
    .publisher(for: myNotification, object: nil).eraseToAnyPublisher()

print(type(of: notificationPublisher))

let  subscriber = notificationPublisher.sink { (notification) in
    print("Printing this message in Subscriber whenever a notification is Posted")

}

NotificationCenter.default.post(name: Notification.Name(rawValue: "MyNotification"), object: 5, userInfo: nil)



