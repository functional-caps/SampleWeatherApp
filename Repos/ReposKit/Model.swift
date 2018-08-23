import UIKit

enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}
//
//protocol GitHubProtocol {
//  func fetchRepos(onComplete completionHandler: (@escaping (Result<[GitHub.Repo], Error>) -> Void))
//}

struct GitHub { //: GitHubProtocol {
    struct Repo: Decodable {
        var archived: Bool
        var description: String?
        var htmlUrl: URL
        var name: String
        var pushedAt: Date?
    }

    var fetchRepos = fetchRepos(onComplete:)
}

private func fetchRepos(onComplete completionHandler: (@escaping (Result<[GitHub.Repo], Error>) -> Void)) {
    dataTask("orgs/pointfreeco/repos", completionHandler: completionHandler)
}

private func dataTask<T: Decodable>(_ path: String, completionHandler: (@escaping (Result<T, Error>) -> Void)) {
    let request = URLRequest(url: URL(string: "https://api.github.com/" + path)!)
    URLSession.shared.dataTask(with: request) { data, urlResponse, error in
        do {
            if let error = error {
                throw error
            } else if let data = data {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                completionHandler(.success(try decoder.decode(T.self, from: data)))
            } else {
                fatalError()
            }
        } catch let finalError {
            completionHandler(.failure(finalError))
        }
        }.resume()
}

struct Analytics {
    struct Event {
        var name: String
        var properties: [String: String]

        static func tappedRepo(_ repo: GitHub.Repo) -> Event {
            return Event(
                name: "tapped_repo",
                properties: [
                    "repo_name": repo.name,
                    "build": Current.bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown",
                    "release": Current.bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
                    "screen_height": String(describing: Current.screen.bounds.height),
                    "screen_width": String(describing: Current.screen.bounds.width),
                    "system_name": Current.device.systemName,
                    "system_version": Current.device.systemVersion,
                    ]
            )
        }
    }

    var track = track(_:)
}

private func track(_ event: Analytics.Event) {
    print("Tracked", event)
}

public struct Environment {
    var analytics = Analytics()
    var date: () -> Date = Date.init
    var gitHub = GitHub()
    var bundle = Bundle.main
    var screen = UIScreen.main
    var device = UIDevice.current
    var produceFormatter: () -> DateComponentsFormatter = { DateComponentsFormatter() }
}

public var Current = Environment()

extension GitHub {
    static let mock = GitHub(fetchRepos: { callback in
        callback(
            .success(
                [
                    GitHub.Repo(archived: false, description: "Blob's blog", htmlUrl: URL(string: "https://www.pointfree.co")!, name: "Bloblog", pushedAt: Date(timeIntervalSinceReferenceDate: 547152021))
                ]
            )
        )
    })
}

extension Analytics {
    static let mock = Analytics(track: { event in
        print("Mock track", event)
    })
}

extension Bundle {
    static let mock = Bundle.main
}

extension UIScreen {
    static let mock = UIScreen.main
}

extension UIDevice {
    static let mock = UIDevice.current
}

public extension Environment {
    static let mock = Environment(
        analytics: .mock,
        date: { Date(timeIntervalSinceReferenceDate: 557152051) },
        gitHub: .mock,
        bundle: .mock,
        screen: .mock,
        device: .mock,
        produceFormatter: {
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: "pl")
            let formatter = DateComponentsFormatter()
            formatter.calendar = calendar
            return formatter
        }
    )
}

//Current = .mock

//Current.gitHub.fetchRepos = { callback in
//  callback(.failure(NSError.init(domain: "co.pointfree", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ooops!"])))
//}


//let reposViewController = ReposViewController.init(
//  date: { Date(timeIntervalSinceReferenceDate: 557152051) },
//  gitHub: GitHubMock.init(result: .failure(NSError.init(domain: "co.pointfree", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ooops!"])))
//)


//import PlaygroundSupport
//PlaygroundPage.current.liveView = vc
