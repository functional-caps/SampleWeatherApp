//: [Previous](@previous)

struct User {
    let id: Int
    let email: String
}

/*

 Exercise 1:

 Find three more standard library APIs that can be used with our get and ^ helpers.

 Answer 1:

 */

// used already: map, reduce, filter, min, max, sorted

^\User.email

//???


/*

 Exercise 2:

 The one downside to key paths being only compiler generated is that we do not get to create new ones ourselves. We only get the ones the compiler gives us.

 And there are a lot of getters and setters that are not representable by key paths. For example, the “identity” key path KeyPath<A, A> that simply returns self for the getter and that setting on it leaves it unchanged. Can you think of any other interesting getters/setters that cannot be represented by key paths?

 Answer 2:

 */

//???

/*

 Exercise 3:

 In our Setters and Key Paths episode we showed how map could kinda be seen as a “setter” by saying:

 “If you tell me how to transform an A into a B, I will tell you how to transform an [A] into a [B].”

 There is also a way to think of map as a “getter” by saying:

 “If you tell me how to get a B out of an A, I will tell you how to get an [B] out of an [A].”

 Try composing get with free map function to construct getters that go even deeper into a structure. You may want to use the data types we defined last time.

 Answer 3:

 */

struct Food {
    var name: String
}

struct Location {
    var name: String
}

struct User2 {
    var favoriteFoods: [Food]
    var location: Location?
    var name: String
}

//^\User2.favoriteFoods

//^\Food.name |> map
//User -> [Food]
//        [Food] -> [String]


let foodNameGetter = ^\User2.favoriteFoods >>> (^\Food.name |> map)
foodNameGetter

let user = User2(favoriteFoods: [Food(name: "aaa")], location: nil, name: "test")
user
    |> ^\User2.favoriteFoods >>> (^\Food.name |> map)


/*

 Exercise 4:

 Repeat the above exercise by seeing how the free optional map can allow you to dive deeper into an optional value to extract out a part.

 Key paths even give first class support for this operation. Do you know what it is?

 Answer 4:

 */

get(\User2.location) >>> (get(\Location.name) |> map)

get(\User2.location?.name)

/*

 Exercise 5:

 Key paths aid us in getter composition for structs, but enums don’t have any stored properties. Write a getter function for Result that plucks out a value if it exists, such that it can compose with get. Use this function with a value in Result<User, String> to return the user’s name.

 Answer 5:

 */

func success<Root, Value, Error>(
    getter: @escaping (Root) -> Value)
    -> (Result<Root, Error>)
    -> Value? {
        return { result -> Value? in
            switch result {
            case .success(let value):
                return getter(value)
            case .failure:
                return nil
            }
        }
}

let result = Result<User, String>.success(User(id: 42, email: "a@b.c"))
result |> (get(\User.email) |> success)

/*

 Exercise 6:

 Key paths work immediately with all fields in a struct, but only work with computed properties on an enum. We saw in Algebra Data Types that structs and enums are really just two sides of a coin: neither one is more important or better than the other.

 What would it look like to define an EnumKeyPath<Root, Value> type that encapsulates the idea of “getting” and “setting” cases in an enum?

 Answer 6:

 */

struct EnumKeyPath<Root, Value>{
    let getter: (Root) -> Value?
    let setter: (Value) -> (Root) -> Root?

    init(getter: @escaping (Root) -> Value?,
         setter: @escaping (Value) -> (Root) -> Root?) {
        self.getter = getter
        self.setter = setter
    }
}

extension EnumKeyPath {
    static func success<E>() -> EnumKeyPath
        where Root == Result<Value, E> {
        return EnumKeyPath(
            getter: { result in
            switch result {
            case .success(let value): return value
            case .failure: return nil
            }
        }
            , setter: { value in
            return { result in
                switch result {
                case .success: return Result<Value, E>.success(value)
                case .failure: return nil
                }
            }
        }
        )
    }

    static func failure<V>() -> EnumKeyPath where Root == Result<V, Value> {
        return EnumKeyPath(
            getter: { result in
                switch result {
                case .success: return nil
                case .failure(let value): return value
                }
            },
            setter: { value in
                return { result in
                    switch result {
                    case .success: return nil
                    case .failure(let value): return Result<V, Value>.failure(value)
                    }
                }
            }
        )
    }
}

let successKp = EnumKeyPath<Result<Int, String>, Int>.success()

let resultKp = Result<Int, String>.success(42)
resultKp |> successKp.getter
resultKp |> successKp.setter(24)

let failureKp = EnumKeyPath<Result<Int, String>, String>.failure()

let resultKp2 = Result<Int, String>.failure("42")
resultKp2 |> failureKp.getter
resultKp2 |> failureKp.setter("24")

/*

 Exercise 7:

 Given a value in EnumKeyPath<A, B> and EnumKeyPath<B, C>, can you construct a value in EnumKeyPath<A, C>?

 Answer 7:

 */

let kp1 = EnumKeyPath<Result<Result<Int, String>, Double>, Result<Int, String>>.success()
let kp2 = EnumKeyPath<Result<Int, String>, Int>.success()


// Result<Result<Int, String>, Double> -> Result<Int, String>?

kp1.getter >>> (kp2.getter |> map)
// Result<Int, String> -> Int? -> Result<Int, String>? -> Int??


// Result<Int, String> -> Int?

(SampleWeatherPlayground_Sources.Result<SampleWeatherPlayground_Sources.Result<Int, String>, Double>) -> Optional<Optional<Int>>

/*

 Exercise 8:

 Given a value in EnumKeyPath<A, C> and a value in EnumKeyPath<B, C>, can you construct a value in EnumKeyPath<Either<A, B>, C>?

 Answer 8:

 */

//: [Next](@next)
