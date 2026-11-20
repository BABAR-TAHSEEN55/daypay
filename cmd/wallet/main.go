package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		logger.Info("health check", "remote", r.RemoteAddr)
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status": "ok"}` + "\n"))
	})
	// Testing endpoint for slow response testing
	// mux.HandleFunc("GET /slow", func(w http.ResponseWriter, r *http.Request) {
	// 	time.Sleep(5 * time.Second)
	// 	w.Write([]byte("done\n"))
	// })

	server := &http.Server{
		Addr:              ":8081",
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	// Root context for the application
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	go func() {
		logger.Info("Wallet service listening", "addr", server.Addr)
		if err := server.ListenAndServe(); err != nil {
			logger.Error("Server error", "error", err)
		}
	}()
	<-ctx.Done()
	logger.Info("Shutting down gracefully")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := server.Shutdown(shutdownCtx); err != nil {
		logger.Error("Shutdown error", "error", )
	}
	logger.Info("Server stopped")
}
