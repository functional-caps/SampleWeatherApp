import SampleWeatherFramework
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    
    //
    // TODO
    //
    // Zmienić completion blocki na paralele, bo teraz jest siara i w compeltion bloku część logiki siedzi osobno
    //
    // Dopisać testy i zobaczyć, gdzie ssie testowanie
    //
    // Playground pod widoki z podpiętym frameworkiem aplikacji -> setup tego
    //
    // Widok: search + table view
    //
    // dorzucić request na forecast
    //
    
    
    
    
    
    
    
    
    // TODO
    // 1. Zrobić jeden request funkcyjnie
    // 2. Zrobić pusty ViewController i najprostszy ViewModel (o ile trzeba, może ViewModel też może być funkcją?)
    // 3. Zrobić Environment i użyć go np. do podawania URLSession
    
    // Szkic z funkcjami
    
    //        let request = addHeaders >>> addBody >>> setMethod // (Request) -> Request
    //
    //        iosify // (Request) -> URLRequest
    //
    //        service // (URLRequest) -> Data
    //
    //        deserializer // (Data) -> JSON
    //
    //        let fetchingForecast = request >>> iosify >>> service(APIconf) >>> deserializer(Forecast) // (Request) -> JSON
    //
    //        let data = Request() |> fetchingForecast // JSON
    
    // Szkic z konfiguracjami na enumach? Co może być sensowną konfiguracją, a co powinno być funkcją?
    
    //        request >>> iosify >>> service(APIconf) /* (Request) -> (DeserializationVariant -> Data) */
    //            >>> deserializer(Forecast) // one of three variants: foo: (Data) -> Int, bar: (Data) -> String, baz: (Data) -> Void
    
    // Może taki patern jako fileprivate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        
        // time for monad transformers!
        fetchCurrentWeather(for: .warsaw)
            .map { dataResult in
                dataResult.flatMap { data in
                    deserialize(into: CurrentWeather.self)(data)
                }
            }
            .map { responseResult in
                responseResult.map(toEither(withR: ErrorResponse.self))
            }
            .map { responseResult in
                responseResult.flatMapError { (error: APIError) -> Result<Either<CurrentWeather, ErrorResponse>, APIError> in
                    if case let .couldNotDeserialize(data, _) = error {
                        return deserialize(into: ErrorResponse.self)(data)
                            .map { $0 |> toEither(withL: CurrentWeather.self) }
                    } else {
                        return .failure(error)
                    }
                }
            }.run { elem in
                print(elem)
            }
        
        
        
//        fetchCurrentWeather(for: .warsaw) {
//            let asd = $0.map { data in
//                deserialize(into: CurrentWeather.self)(data)
//                    .map { Either<CurrentWeather, ErrorResponse>.left($0) }
//                    .flatMapError { (error: APIError) -> Result<Either<CurrentWeather, ErrorResponse>, APIError> in
//                        if case let .couldNotDeserialize(data, _) = error {
//                            return deserialize(into: ErrorResponse.self)(data)
//                                .map {
//                                    Either<CurrentWeather, ErrorResponse>.right($0)
//                                }
//                        } else {
//                            return .failure(error)
//                        }
//                }
//            }
//            print(asd)
//        }
        return true
    }
}
