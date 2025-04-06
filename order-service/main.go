package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	Server struct {
		Port string `mapstructure:"port"`
	} `mapstructure:"server"`
	UserService struct {
		Host string `mapstructure:"host"`
	} `mapstructure:"user_service"`
}

type Order struct {
	ID      string  `json:"id"`
	UserID  string  `json:"user_id"`
	Product string  `json:"product"`
	Price   float64 `json:"price"`
}

type CreateOrderRequest struct {
	UserID  string  `json:"user_id"`
	Product string  `json:"product"`
	Price   float64 `json:"price"`
}

type OrderService struct {
	storage         map[string]Order
	userServiceHost string
}

func NewOrderService(userServiceHost string) *OrderService {
	return &OrderService{
		storage:         make(map[string]Order),
		userServiceHost: userServiceHost,
	}
}

func (s *OrderService) validateUser(userID string) error {
	url := s.userServiceHost + "/users?id=" + userID
	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to call user service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return errors.New("user not found")
	}
	return nil
}

func (s *OrderService) createOrder(w http.ResponseWriter, r *http.Request) {
	var req CreateOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if err := s.validateUser(req.UserID); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	orderID := fmt.Sprintf("order-%d", len(s.storage)+1)
	order := Order{
		ID:      orderID,
		UserID:  req.UserID,
		Product: req.Product,
		Price:   req.Price,
	}
	s.storage[orderID] = order

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(order)
}

func (s *OrderService) getOrders(w http.ResponseWriter, r *http.Request) {
	var orderList []Order
	for _, order := range s.storage {
		orderList = append(orderList, order)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(orderList)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK")
}

func loadConfig() (Config, error) {
	cfg := Config{}

	// Initialize new viper instance
	v := viper.New()
	v.SetEnvPrefix("ORDER_SERVICE")
	v.AutomaticEnv()

	// Read from config.yaml
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")

	err := viper.ReadInConfig()
	if err != nil {
		return cfg, err
	}

	err = viper.Unmarshal(&cfg)
	if err != nil {
		return cfg, err
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

	orderService := NewOrderService(cfg.UserService.Host)

	http.HandleFunc("/orders", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			orderService.getOrders(w, r)
		case http.MethodPost:
			orderService.createOrder(w, r)
		default:
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		}
	})
	http.HandleFunc("/health", healthCheck)

	log.Printf("Order service started on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
