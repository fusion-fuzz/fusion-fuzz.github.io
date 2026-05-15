module {
  func @main() {
    %html = "<!DOCTYPE HTML><html><body><div></div></body></html>" : !llvm.string
    %dom = "createDom"() : !llvm.ptr
    "loadHtml"(%dom, %html) : () 

    %divs = "getDivs"(%dom) : !llvm.ptr
    %count = "getCount"(%divs) : i32
    %zero = constant 0 : i32
    %one = constant 1 : i32

    %index = "createIndex"() : !llvm.ptr
    "forLoop"(%zero, %count, %one, %index) : () {
      %div = "getDiv"(%divs, %index) : !llvm.ptr
      %fragment = "createDocumentFragment"() : !llvm.ptr
      "appendXml"(%fragment, "<p>Hi!</p>") : ()
      "replaceWith"(%div, %fragment) : ()
    }

    "saveHtml"(%dom) : !llvm.string
    "cleanup"(%dom) : ()
  }
}