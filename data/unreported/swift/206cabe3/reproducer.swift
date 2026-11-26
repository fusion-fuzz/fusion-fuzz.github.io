class Person {
  var secondLocation: (() -> Place)!
}
struct Place {
  typealias Callback = () -> ()
  let person: Person
  let callback: Callback
  let wrappedValue: String
}
