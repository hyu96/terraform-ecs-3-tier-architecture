package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	Server struct {
		Port string `json:"port"`
	} `json:"server"`
}

type User struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type UserService struct {
	users map[string]User
}

func NewUserService() *UserService {
	return &UserService{
		users: map[string]User{
			"1": {ID: "1", Name: "Alice", Email: "alice@example.com"},
			"2": {ID: "2", Name: "Bob", Email: "bob@example.com"},
		},
	}
}

func (s *UserService) getUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("id")
	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	user, exists := s.users[userID]
	if !exists {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK")
}

func loadConfig() (Config, error) {
	cfg := Config{}

	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")

	if err := viper.ReadInConfig(); err != nil {
		return cfg, fmt.Errorf("failed to read config: %w", err)
	}

	if err := viper.Unmarshal(&cfg); err != nil {
		return cfg, fmt.Errorf("failed to parse config: %w", err)
	}

	if cfg.Server.Port == "" {
		cfg.Server.Port = "8080"
	}

	return cfg, nil
}

func main() {
	cfg, err := loadConfig()
	if err != nil {
		log.Printf("Warning: %v", err)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = cfg.Server.Port
	}

	userService := NewUserService()

	http.HandleFunc("/users", userService.getUser)
	http.HandleFunc("/health", healthCheck)

	log.Printf("User service started on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
