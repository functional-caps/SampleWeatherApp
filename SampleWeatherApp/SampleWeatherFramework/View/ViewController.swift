import UIKit

final public class ViewController: UIViewController, UISearchResultsUpdating {
    
    private let tableView = UITableView()
    
    override public func loadView() {
        view = tableView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .blue
        
        fetchForecastWeather(for: .warsaw)
//            .map({ String.init(data: $0, encoding: .utf8) })
            .map(deserialize(into: ForecastWeather.self))
            .run {
                print($0)
            }
        
//        fetchCurrentWeather(for: .warsaw)
//            .map(deserialize(into: CurrentWeather.self))
//            .map(toEither(withRight: ErrorResponse.self))
//            .map { (error: APIError) -> Result<Either<CurrentWeather, ErrorResponse>, APIError> in
//                guard case let .couldNotDeserialize(data, _) = error else { return .failure(error) }
//                return deserialize(into: ErrorResponse.self)(data).map(toEither(withLeft: CurrentWeather.self))
//            }.run { elem in
//                print(elem)
//        }
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text)
    }
}
