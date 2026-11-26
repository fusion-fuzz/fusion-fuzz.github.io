import Foundation

let data = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(base64Encoded: "YToxOntpOjA7czo5OiJBUHBTZXR0aW5ncyI7fQ==")!) as! Array<Any>

print(data)
