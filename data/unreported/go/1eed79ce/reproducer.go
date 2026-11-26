package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
)

func httpServer(response string) (int, string, *os.File) {
	// Start a simple HTTP server using Go's standard library.
	cmd := exec.Command("go", "run", "server.go") // Assuming server.go mimics the PHP server.inc functionality
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Create a temporary file to simulate output handling
	output, err := os.CreateTemp("", "output")
	if err != nil {
		fmt.Println("Error creating temporary file:", err)
		os.Exit(1)
	}

	// Start the server
	if err := cmd.Start(); err != nil {
		fmt.Println("Error starting server:", err)
		os.Exit(1)
	}

	return cmd.Process.Pid, "http://localhost:8080", output
}
type S struct {
	i int64
	s string
}

type Foo struct {
	value S
}

func main_dbedf61() {
	box := Foo{value: S{i: 0, s: ""}}
	x := int64(123)
	v := box.value
	v.i ^= x
	box.value = v
	fmt.Println(box.value.i, box.value.s)
}

func httpServerKill(pid int) {
	// Kill the server process
	if process, err := os.FindProcess(pid); err == nil {
		process.Kill()
	}
}

func main() {
	responses := "HTTP/1.1 200 OK\r\n\r\n"

	pid, uri, output := httpServer(responses)
	defer os.Remove(output.Name())

	client := &http.Client{}
	req, err := http.NewRequest("GET", uri, nil)
	if err != nil {
		fmt.Println("Error creating request:", err)
		return
	}
	
	req.Header.Set("RandomHeader", "localhost:8080")
	req.Header.Set("Cookie", "foo=bar")
	req.Header.Set("Host", "userspecifiedvalue")

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error during request:", err)
		return
	}
	defer resp.Body.Close()

	io.Copy(output, resp.Body)
	output.Seek(0, io.SeekStart)

	content, err := io.ReadAll(output)
	if err != nil {
		fmt.Println("Error reading output:", err)
	} else {
		fmt.Print(string(content))
	}

	httpServerKill(pid)
}
