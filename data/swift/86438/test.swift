var test = result
let htmlContent = "<a href=\"https://PHP.net\">hello</a>"
guard let doc = try? HTMLDocument(string: htmlContent) else { fatalError("Failed to create document") }
let xpath = XPath(doc)
var result = xpath.query("//a[foo:strtolower(string(@href)) = 'https://php.net']")
class HTMLDocument {
    init(string: String) {}
}
