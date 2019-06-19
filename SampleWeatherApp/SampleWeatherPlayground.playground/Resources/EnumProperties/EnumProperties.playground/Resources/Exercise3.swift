
enum Node {
  case el(tag: String, attributes: [String: String], children: [Node])
  case text(String)
}
