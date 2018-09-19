//: [Previous](@previous)

/*

 Today’s episode was powered by playground-driven development, but we’re talking about real-world code and that kind of code usually lives in an application target. The following exercises explore how to apply playground-driven development to actual application code.

 Download the episode code and copy it into a new iOS project called “Repos”. The app should display the repos navigation controller as the window’s root view controller.

 Add a framework target to the project called “ReposKit” and embed it in the Repos app. Move all of our application code (aside from the app delegate) to ReposKit. Make sure that the source files are members of the framework target, not the app target. Repos should import ReposKit into the app delegate in order to access and instantiate the ReposViewController. Build the application to make sure everything still works (you will need to make some types and functions public).

 Create an iOS playground and drag it into your app project. Import ReposKit, instantiate a ReposViewController, and set it as the playground’s live view. You can use our original playground code as a reference.

 Swap out the Current, live world for our mock one. This playground page can now act as a living reference for this screen! You can modify the mock to test different states, and to test changes to the view controller, you can rebuild ReposKit.

 There are a few dependencies in the application that we didn’t cover. Let’s explore controlling them over a couple exercises.

 The analytics client is calling out to several singletons: Bundle.main, UIScreen.main, and UIDevice.current. Extract these dependencies to Environment. What are some advantages of controlling these dependencies?

 DateComponentsFormatter can produce different strings for different languages and locales, but defaults to the device locale. Extract this dependency to Environment, control it on the formatter, and demonstrate how mocking Current allows you to test formatting over different languages and locales.

 */

/*

 A.foo()
 A.bar()
 A.baz()

 X.bar()

 1) od góry:

 protocol X { func bar() }
 extension A: X {}


 2) od dołu:

 class X : A {
     func foo() { noop() }
     func bar() { super.bar }
     func baz() { noop() }
 }


 3) przez dodanie scope:

 struct X {
     private let a: A
     func bar() { a.bar }
 }

 X(a: a)


 4) przez odjęcie scope:

 Tagged<A, () -> Void>

 struct Tagged2<Tag, A, B> {
     let a: A
     let b: B
 }

 typealias XBar = () -> Void
 let xbar: XBar = A.bar


 5) przez transformatę scope:

 struct X1<A, B> {
     private let f: (A) -> B
 }

 X1(f: a.bar)

 struct X2<A, B, C, D> {
     private let f1: (A) -> B
     private let f2: (C) -> D
 }

 X2(f1: a.bar, f2: a.foo)

 */


//: [Next](@next)
