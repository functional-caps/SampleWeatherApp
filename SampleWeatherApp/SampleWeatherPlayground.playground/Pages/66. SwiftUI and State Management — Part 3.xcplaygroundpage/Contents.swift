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
    print(String(describing: p))
}

struct ContentView: View {

    @ObjectBinding var state: AppState

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritePrimes(state: FavoritePrimesState(state: self.state))) {
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
        didSet { self.willChange.send() }
    }
    
    var favouritePrimes: [Int] = [] {
        didSet { self.willChange.send() }
    }
    
    var loggedInUser: User? {
        didSet { self.willChange.send() }
    }

    var activityFeed: [Activity] = [] {
      didSet { self.willChange.send() }
    }
    
    var willChange = PassthroughSubject<Void, Never>()
    
    struct Activity {
      let timestamp: Date
      let type: ActivityType

      enum ActivityType {
        case addedFavoritePrime(Int)
        case removedFavoritePrime(Int)
      }
    }
    
    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

extension AppState {
  func addFavoritePrime() {
    self.favouritePrimes.append(self.count)
    self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(self.count)))
  }

  func removeFavoritePrime(_ prime: Int) {
    self.favouritePrimes.removeAll(where: { $0 == prime })
    self.activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
  }

  func removeFavoritePrime() {
    self.removeFavoritePrime(self.count)
  }

  func removeFavoritePrimes(at indexSet: IndexSet) {
    for index in indexSet {
      self.removeFavoritePrime(self.favouritePrimes[index])
    }
  }
}

class FavoritePrimesState: BindableObject {
    
    var willChange: PassthroughSubject<Void, Never> { self.state.willChange }
    
    private var state: AppState
    init(state: AppState) {
        self.state = state
    }
    
    var favouritePrimes: [Int] {
        get { self.state.favouritePrimes }
        set { self.state.favouritePrimes = newValue }
    }
    
    var activityFeed: [AppState.Activity] {
            get { self.state.activityFeed }
            set { self.state.activityFeed = newValue }
        }
}

struct FavoritePrimes: View {
  @ObjectBinding var state: FavoritePrimesState

  var body: some View {
    List {
      ForEach(self.state.favouritePrimes) { prime in
        Text("\(prime)")
      }
      .onDelete(perform: { indexSet in
        for index in indexSet {
            let prime = self.state.favouritePrimes.remove(at: index)
            self.state.activityFeed.append(AppState.Activity.init(
                timestamp: Date(), type: .removedFavoritePrime(prime)
            ))
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
    @State var isNthPrimeButtonDisabled: Bool = false

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
            Button(action: self.nthPrimeButtonAction) {
              Text("What's the \(ordinal(self.state.count)) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
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
    
    func nthPrimeButtonAction() {
                self.isNthPrimeButtonDisabled = true
                nthPrime(self.state.count) { prime in
                    self.alertNthPrime = prime
                    self.isNthPrimeButtonDisabled = false
                }
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
                        self.state.favouritePrimes.removeAll(where: { $0 == self.state.count })
                        self.state.activityFeed.append(AppState.Activity.init(
                            timestamp: Date(), type: .removedFavoritePrime(self.state.count)
                        ))
                    }) {
                        Text("Remove from favourite primes")
                    }
                } else {
                    Button(action: {
                        self.state.favouritePrimes.append(self.state.count)
                        self.state.activityFeed.append(AppState.Activity.init(
                            timestamp: Date(), type: .addedFavoritePrime(self.state.count)
                        ))
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
