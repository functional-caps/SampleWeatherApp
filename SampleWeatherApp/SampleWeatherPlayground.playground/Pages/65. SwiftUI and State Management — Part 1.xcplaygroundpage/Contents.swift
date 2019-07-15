////: [Previous](@previous)
//
//import Foundation
//import SwiftUI
//
//struct ContentView: View {
//
//    @ObjectBinding var state: AppState
//
//    var body: some View {
//        NavigationView {
//            List {
//                NavigationLink(destination: CounterView(state: state)) {
//                    Text("Counter demo")
//                }
//                NavigationLink(destination: EmptyView()) {
//                    Text("Favourite primes")
//                }.navigationBarTitle("State management")
//            }
//        }
//    }
//}
//
//private func ordinal(_ n: Int) -> String {
//    let formatter = NumberFormatter()
//    formatter.numberStyle = .ordinal
//    return formatter.string(for: n) ?? ""
//}
//
//import Combine
//
//class AppState: BindableObject {
//    var count: Int = 0 {
//        didSet {
//            self.didChange.send()
//        }
//    }
//
//    var didChange = PassthroughSubject<Void, Never>()
//}
//
//struct CounterView: View {
//
//    @ObjectBinding var state: AppState
//
//    var body: some View {
//        VStack {
//            HStack {
//                Button(action: { self.state.count -= 1 }) {
//                    Text("-")
//                }
//
//                Text("\(self.state.count)")
//                Button(action: { self.state.count += 1 }) {
//                    Text("+")
//                }
//            }
//            Button(action: { }) {
//                Text("Is this prime?")
//            }
//            Button(action: {}) {
//                Text("What is \(ordinal(self.state.count)) prime?")
//            }
//        }
//        .font(.title)
//        .navigationBarTitle("Counter demo")
//
//    }
//}
//
//import PlaygroundSupport
//
//PlaygroundPage.current.liveView =
//    UIHostingController(rootView: ContentView(state: AppState()))

import Foundation
import SwiftUI

struct ContentView: View {
    
    @ObjectBinding var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("Favourite primes")
                }.navigationBarTitle("State management")
            }
        }
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

import Combine

class AppState: BindableObject, Codable {
    
    enum CodingKeys: CodingKey {
        case count
    }
    
    var count: Int = 0 {
        didSet {
            self.didChange.send()
            let data = try! JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: "AppState.count")
        }
    }
    
    var didChange = PassthroughSubject<Void, Never>()
    
    static func read(from data: Data?) -> AppState {
        return data.flatMap { try? JSONDecoder().decode(AppState.self, from: $0) } ?? AppState()
    }
}

struct CounterView: View {
    
    @ObjectBinding var state: AppState
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.state.count -= 1 }) {
                    Text("-")
                }
                
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                    Text("+")
                }
            }
            Button(action: { }) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
            .navigationBarTitle("Counter demo")
        
    }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(rootView:
    ContentView(state:
        AppState.read(from: UserDefaults.standard.data(forKey: "AppState.count"))
    )
)

/*
 
 Exercise 1.
 
 Let’s make the state even more persistent by saving the state whenever a change is made and loading the state when the app launches. This can be done in a few steps:
 
    * Make AppState conform to Codable. Because of the PassthroughSubject didChange property, you unfortunately must manually specify the other CodingKeys or manually implement encoding and decoding.
 
    * Tap into each didSet on the model and save the JSON representation of the state to UserDefaults.
 
    * When the root ContentView is created for the playground live view load the AppState from UserDefaults.
 
    * Once you have accomplished this your data will persist across multiple runs of the playground! However, there are quite a few problems with it. Implementing Codable is annoying due to the PassthroughSubject, we are saving the state to UserDefaults on every state change, which is probably too inefficient, and we have to repeat that work for each didSet entry point. We will explore better ways of dealing with this soon 😄.
 
 */

// Done above

/*

 Exercise 2.
 
 Search for an algorithm online that checks if an integer is prime, and port it to Swift.
 
 */

//function is_prime(n)
//    if n ≤ 3
//        return n > 1
//    else if n mod 2 = 0 or n mod 3 = 0
//        return false
//    let i ← 5
//    while i * i ≤ n
//        if n mod i = 0 or n mod (i + 2) = 0
//            return false
//        i ← i + 6
//    return true

func isPrime(_ n: Int) -> Bool {
    if n <= 3 {
        return n > 1
    } else if n % 2 == 0 || n % 3 == 0 {
        return false
    }
    var i = 5
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 {
            return false
        }
        i += 6
    }
    return true
}

isPrime(0)
isPrime(1)
isPrime(2)
isPrime(3)
isPrime(4)
isPrime(5)
isPrime(6)
isPrime(7)
isPrime(8)
isPrime(9)
isPrime(10)
isPrime(11)
isPrime(31)
isPrime(32)

/*

 Exercise 3.
 
 Make the counter Text view green when the current count value is prime, and red otherwise.
 
 */



/*

 Exercise 4.
 
 To present modals in SwiftUI one uses the presentation method on views that takes a single argument of an optional Modal value. If this value is present then the modal will be presented, and if it’s nil the modal will be dismissed (or if no modal is showing, nothing will happen).
 
 Add an additional @State value to our CounterView and use it to show and hide the modal when the “Is this prime?” button is tapped.
 
 */




/*

 Exercise 5.
 
 Add a var favoritePrimes: [Int] field to our AppState, and make sure to ping didChange when this value is mutated.
 
 Use this new favoritePrimes state to render a “Add to favorite primes” / “Remove from favorite primes” button in the modal. Also hook up the action on this button to remove or add the current counter value to the list of favorite primes.
 
 */




/*
 
 Exercise 6.
 
 Right now it’s cumbersome to add new state to our AppState class. We have to always remember to ping didChange whenever any of our fields is mutated and even more work is needed if we wanted to bundle up a bunch of fields into its own state class.
 
 These problems can be fixed by creating a generic class Store<A> that wraps access to a single value type A. Implement this class and replace all instances of AppState in our application with Store<AppState>.
 
 */






//: [Next](@next)
