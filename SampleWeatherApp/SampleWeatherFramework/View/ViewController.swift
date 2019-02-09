import UIKit

final public class ViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        fetchCurrentWeather(for: .warsaw)
            .map(deserialize(into: CurrentWeather.self))
            .map(toEither(withR: ErrorResponse.self))
            .map { (error: APIError) -> Result<Either<CurrentWeather, ErrorResponse>, APIError> in
                guard case let .couldNotDeserialize(data, _) = error else { return .failure(error) }
                return deserialize(into: ErrorResponse.self)(data).map(toEither(withL: CurrentWeather.self))
            }.run { elem in
                print(elem)
        }
    }
}
