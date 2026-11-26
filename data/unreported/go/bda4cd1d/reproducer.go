package main

import (
	"fmt"
	"bytes"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
)

func main() {
	a := make(map[string]int)
	a["not packed"] = 1
	for i := 0; i < 1000000; i++ {
		a[fmt.Sprint(i)] = 1
	}
	fmt.Print("Success")
}
type FP struct{}

func (f *FP) GetIt(opt string) string {
    if opt == "" {
        return "zzz"
    }
    return opt
}

type LocalSoapServer struct {
    handlerFunc http.HandlerFunc
}

func NewLocalSoapServer() *LocalSoapServer {
    fs := &FP{}
    server := &LocalSoapServer{
        handlerFunc: func(w http.ResponseWriter, r *http.Request) {
            requestBody, err := ioutil.ReadAll(r.Body)
            if err != nil {
                http.Error(w, "Cannot read request", http.StatusInternalServerError)
                return
            }
            response := handleSoapRequest(fs, requestBody)
            w.Write(response)
        },
    }
    return server
}

func handleSoapRequest(fs *FP, requestBody []byte) []byte {
    // Simplified SOAP request handler logic
    return []byte(fmt.Sprintf("<Response>%s</Response>", fs.GetIt(string(requestBody))))
}

type LocalSoapClient struct {
    server *httptest.Server
}

func NewLocalSoapClient() *LocalSoapClient {
    server := NewLocalSoapServer()
    return &LocalSoapClient{
        server: httptest.NewServer(server.handlerFunc),
    }
}

func (c *LocalSoapClient) Call(action string, request string) string {
    httpRequest, err := http.NewRequest("POST", c.server.URL, bytes.NewBuffer([]byte(request)))
    if err != nil {
        return "Error creating request"
    }

    response, err := http.DefaultClient.Do(httpRequest)
    if err != nil {
        return "Error making request"
    }
    defer response.Body.Close()

    responseBody, err := ioutil.ReadAll(response.Body)
    if err != nil {
        return "Error reading response"
    }

    return string(responseBody)
}

func main_dc88e4c() {
    cl := NewLocalSoapClient()
    fmt.Println(cl.Call("get_it", "aaa"))
    fmt.Println(cl.Call("get_it", ""))
    fmt.Println(cl.Call("get_it", "\x00"))
}

type FP_bc88e4c struct{}

func (f *FP_bc88e4c) GetIt(opt string) string {
    if opt == "" {
        return "zzz"
    }
    return opt
}

type LocalSoapServer_bc88e4c struct {
    handlerFunc http.HandlerFunc
}

func NewLocalSoapServer_bc88e4c() *LocalSoapServer_bc88e4c {
    fs := &FP_bc88e4c{}
    server := &LocalSoapServer_bc88e4c{
        handlerFunc: func(w http.ResponseWriter, r *http.Request) {
            requestBody, err := ioutil.ReadAll(r.Body)
            if err != nil {
                http.Error(w, "Cannot read request", http.StatusInternalServerError)
                return
            }
            response := handleSoapRequest_bc88e4c(fs, requestBody)
            w.Write(response)
        },
    }
    return server
}

func handleSoapRequest_bc88e4c(fs *FP_bc88e4c, requestBody []byte) []byte {
    // Simplified SOAP request handler logic
    return []byte(fmt.Sprintf("<Response>%s</Response>", fs.GetIt(string(requestBody))))
}

type LocalSoapClient_bc88e4c struct {
    server *httptest.Server
}

func NewLocalSoapClient_bc88e4c() *LocalSoapClient_bc88e4c {
    server := NewLocalSoapServer_bc88e4c()
    return &LocalSoapClient_bc88e4c{
        server: httptest.NewServer(server.handlerFunc),
    }
}

func (c *LocalSoapClient_bc88e4c) Call(action string, request string) string {
    httpRequest, err := http.NewRequest("POST", c.server.URL, bytes.NewBuffer([]byte(request)))
    if err != nil {
        return "Error creating request"
    }

    response, err := http.DefaultClient.Do(httpRequest)
    if err != nil {
        return "Error making request"
    }
    defer response.Body.Close()

    responseBody, err := ioutil.ReadAll(response.Body)
    if err != nil {
        return "Error reading response"
    }

    return string(responseBody)
}

func main_bc88e4c() {
    cl := NewLocalSoapClient_bc88e4c()
    fmt.Println(cl.Call("get_it", "aaa"))
    fmt.Println(cl.Call("get_it", ""))
    fmt.Println(cl.Call("get_it", "\x00"))
}
