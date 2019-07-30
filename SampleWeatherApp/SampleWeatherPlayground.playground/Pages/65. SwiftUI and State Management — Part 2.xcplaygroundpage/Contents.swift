////: [Previous](@previous)

import Foundation
import SwiftUI
import Combine

struct WolframAlphaResult: Decodable {
    let queryresult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]
            
            struct SubPod: Decodable {
                let plaintext: String
            }
        }
    }
}

let wolframAlphaApiKey: String = "LH6KXA-JXGJGRAKQ9"

func wolphramAlpha(query: String,
                   callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: wolframAlphaApiKey)
    ]
    
    URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
        callback(
            data.flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
        )
    }
    .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolphramAlpha(query: "prime \(n)") { result in
        callback(
            result.flatMap {
                $0.queryresult
                    .pods
                    .first(where: { $0.primary == .some(true) })?
                    .subpods
                    .first?
                    .plaintext
            }
            .flatMap(Int.init)
        )
    }
}

nthPrime(1_000) { p in
    print(p)
}

struct ContentView: View {

    @ObjectBinding var state: AppState

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritePrimes(state: self.state)) {
                  Text("Favorite primes")
                }
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

class AppState: BindableObject {
    
    typealias PublisherType = PassthroughSubject<Void, Never>
    
    var count: Int = 0 {
        didSet {
            self.willChange.send()
        }
    }
    
    var favouritePrimes: [Int] = [] {
        didSet { self.willChange.send() }
    }

    var willChange = PassthroughSubject<Void, Never>()
}

struct FavoritePrimes: View {
  @ObjectBinding var state: AppState

  var body: some View {
    List {
      ForEach(self.state.favouritePrimes) { prime in
        Text("\(prime)")
      }
      .onDelete(perform: { indexSet in
        for index in indexSet {
          self.state.favouritePrimes.remove(at: index)
        }
      })
    }
    .navigationBarTitle(Text("Favorite Primes"))
  }
}

struct CounterView: View {

    @ObjectBinding var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: Int?

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
            Button(action: { self.isPrimeModalShown = true }) {
                Text("Is this prime?")
            }
            Button(action: {
              nthPrime(self.state.count) { prime in
                self.alertNthPrime = prime
              }
            }) {
              Text("What's the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .presentation(isPrimeModalShown
            ? Modal(
                IsPrimeModalView(state: self.state),
                onDismiss: { self.isPrimeModalShown = false }
            )
            : nil)
//        .presentation(self.$alertNthPrime) { n in
//            Alert(title: Text("The nth \(ordinal(self.state.count)) prime is \(n)"),
//                  dismissButton: .default(Text("Ok")))
//        }
    }
}

func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true}
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

struct IsPrimeModalView: View {
    
    @ObjectBinding var state: AppState
    
    var body: some View {
        VStack {
            if isPrime(self.state.count) {
                Text("\(self.state.count) is prime 🎉")
                if self.state.favouritePrimes.contains(self.state.count) {
                    Button(action: {
                        self.state.favouritePrimes.removeAll(
                            where: { $0 == self.state.count }
                        )
                    }) {
                        Text("Remove from favourite primes")
                    }
                } else {
                    Button(action: {
                        self.state.favouritePrimes.append(self.state.count)
                    }) {
                        Text("Save to favourite primes")
                    }
                }
            } else {
                Text("\(self.state.count) is not prime 😿")
            }
        }
    }
}


import PlaygroundSupport

PlaygroundPage.current.liveView =
    UIHostingController(rootView: ContentView(state: AppState()))
