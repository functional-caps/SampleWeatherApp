    //
    // TODO
    //
    // Przejrzeć implementacje z Prelude typowych typów
    //
    // Czy można wyciągnąć Environment jako framework?
    // 
    // ✅ Widok: search + table view
    //
    // dorzucić request na forecast
    //
    
    
    
    //
    // TODO
    //
    // ✅ Zmienić completion blocki na paralele, bo teraz jest siara i w compeltion bloku część logiki siedzi osobno
    //
    // ✅ Dopisać testy i zobaczyć, gdzie ssie testowanie
    //
    // ✅ Playground pod widoki z podpiętym frameworkiem aplikacji -> setup tego
    //
    // ✅ Widok: search + table view
    //
    // 🚫 dorzucić request na forecast
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
