// ngrok_upload.go
package main

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"

	ngrok "golang.ngrok.com/ngrok"
	"golang.ngrok.com/ngrok/config"
)

func uploadHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		fmt.Fprint(w, `
			<html><body>
			<h2>Upload File</h2>
			<form method="POST" enctype="multipart/form-data">
				<input type="file" name="file">
				<input type="submit" value="Upload">
			</form>
			</body></html>
		`)
	case http.MethodPost:
		file, handler, err := r.FormFile("file")
		if err != nil {
			http.Error(w, "File upload error", http.StatusBadRequest)
			return
		}
		defer file.Close()

		dst, err := os.Create(handler.Filename)
		if err != nil {
			http.Error(w, "Cannot save file", 500)
			return
		}
		defer dst.Close()

		io.Copy(dst, file)
		fmt.Fprintf(w, "File %s uploaded successfully.", handler.Filename)
	}
}

func main() {
	fmt.Println("Starting server...")
	http.HandleFunc("/", uploadHandler)

	// Start ngrok tunnel
	ctx := context.Background()
	fmt.Println("Initializing ngrok tunnel...")
	tun, err := ngrok.Listen(ctx,
		config.HTTPEndpoint(),
		ngrok.WithAuthtoken("3bYaY5mMkfVkynvhSSPya_2ev1vAoY5Maby7dFDMsoc"),
	)
	if err != nil {
		fmt.Printf("⚠️  Warning: Failed to start tunnel: %v\n", err)
		fmt.Println("Make sure you have ngrok installed and authenticated")
		os.Exit(1)
	}

	fmt.Printf("🚀 Public URL: %s\n", tun.URL())
	fmt.Println("📥 File upload server ready...")
	
	fmt.Printf("Starting HTTP server on URL: %s\n", tun.URL())
	err = http.Serve(tun, nil)
	if err != nil {
		fmt.Printf("HTTP serve error: %v\n", err)
		os.Exit(1)
	}
}
