//: [Previous](@previous)

/*

 Exercise 1:

 Find three more standard library APIs that can be used with our get and ^ helpers.

 Answer 1:


 */

/*

 Exercise 2:

 The one downside to key paths being only compiler generated is that we do not get to create new ones ourselves. We only get the ones the compiler gives us.

 And there are a lot of getters and setters that are not representable by key paths. For example, the “identity” key path KeyPath<A, A> that simply returns self for the getter and that setting on it leaves it unchanged. Can you think of any other interesting getters/setters that cannot be represented by key paths?

 Answer 2:


 */

/*

 Exercise 3:

 In our Setters and Key Paths episode we showed how map could kinda be seen as a “setter” by saying:

 “If you tell me how to transform an A into a B, I will tell you how to transform an [A] into a [B].”

 There is also a way to think of map as a “getter” by saying:

 “If you tell me how to get a B out of an A, I will tell you how to get an [B] out of an [A].”

 Try composing get with free map function to construct getters that go even deeper into a structure. You may want to use the data types we defined last time.

 Answer 3:


 */

/*

 Exercise 4:

 Repeat the above exercise by seeing how the free optional map can allow you to dive deeper into an optional value to extract out a part.

 Key paths even give first class support for this operation. Do you know what it is?

 Answer 4:


 */

/*

 Exercise 5:

 Key paths aid us in getter composition for structs, but enums don’t have any stored properties. Write a getter function for Result that plucks out a value if it exists, such that it can compose with get. Use this function with a value in Result<User, String> to return the user’s name.

 Answer 5:


 */

/*

 Exercise 6:

 Key paths work immediately with all fields in a struct, but only work with computed properties on an enum. We saw in Algebra Data Types that structs and enums are really just two sides of a coin: neither one is more important or better than the other.

 What would it look like to define an EnumKeyPath<Root, Value> type that encapsulates the idea of “getting” and “setting” cases in an enum?

 Answer 6:


 */

/*

 Exercise 7:

 Given a value in EnumKeyPath<A, B> and EnumKeyPath<B, C>, can you construct a value in EnumKeyPath<A, C>?

 Answer 7:


 */

/*

 Exercise 8:

 Given a value in EnumKeyPath<A, C> and a value in EnumKeyPath<B, C>, can you construct a value in EnumKeyPath<Either<A, B>, C>?

 Answer 8:

 */

//: [Next](@next)
