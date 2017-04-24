import Foundation

var url = URL(string: "/foo/bar?buz=qux")
url = URL(string: "https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value&hello=world=foo#ref")

url?.absoluteString
url?.absoluteURL
url?.baseURL
url?.dataRepresentation
url?.debugDescription
url?.fragment
url?.hasDirectoryPath
url?.hashValue
url?.host
url?.isFileURL
url?.lastPathComponent
url?.password
url?.path
url?.pathComponents
url?.pathExtension
url?.port
url?.query
url?.relativePath
url?.scheme
url?.standardized
//url?.standardizedFileURL
url?.user

var urlComponents = URLComponents(string: "https://johnny:p4ssw0rd@www.example.com:443/script.ext;param=value?query=value&hello=world#ref")

urlComponents?.queryItems