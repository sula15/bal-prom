# E-Commerce API - Ballerina Implementation

This project is a Ballerina implementation of a simple e-commerce REST API with Prometheus monitoring and Grafana visualization.

## Project Structure

```
e_commerce_bal/
├── Ballerina.toml        # Project configuration
├── Config.toml           # Application configuration
├── Dependencies.toml     # Auto-generated dependencies
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile            # Dockerfile for the Ballerina application
├── prometheus/
│   └── prometheus.yml    # Prometheus configuration
├── grafana/              # Grafana dashboards and configuration
└── modules/              # Source code organized as Ballerina modules
    ├── main.bal          # Main service
    ├── metrics.bal       # Metrics definitions
    ├── models/           # Data models module
    │   ├── module.bal    # Module declaration
    │   ├── product.bal
    │   ├── order.bal
    │   ├── user.bal
    │   └── cart.bal
    ├── routes/           # API routes module
    │   ├── module.bal    # Module declaration
    │   ├── products.bal
    │   ├── orders.bal
    │   ├── users.bal
    │   └── cart.bal
    └── utils/            # Utility functions module
        ├── module.bal    # Module declaration
        └── timestamp.bal
```

## Prerequisites

- [Ballerina](https://ballerina.io/downloads/) (version 2201.8.0 or later)
- [Docker](https://www.docker.com/get-started/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Running the Application

### Using Ballerina CLI

1. Navigate to the project directory
2. Run the Ballerina application:
   ```
   bal run
   ```

### Using Docker Compose

1. Navigate to the project directory
2. Start all services:
   ```
   docker-compose up -d
   ```

## Available Endpoints

- API: `http://localhost:3000/`
- Prometheus: `http://localhost:9091/`
- Grafana: `http://localhost:3001/` (username: admin, password: password)

## API Endpoints

### Products
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### Orders
- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create new order
- `PATCH /api/orders/{id}/status` - Update order status

### Users
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Deactivate user

### Cart
- `GET /api/cart/user/{userId}` - Get cart by user ID
- `POST /api/cart/user/{userId}` - Create or update cart
- `POST /api/cart/user/{userId}/product` - Add product to cart
- `DELETE /api/cart/user/{userId}/product/{productId}` - Remove product from cart
- `DELETE /api/cart/user/{userId}` - Clear cart

## Monitoring

The application includes built-in Prometheus metrics for monitoring:
- HTTP request count and duration
- Product views and creations
- Order placements and status updates
- User activity
- Cart operations
- Database operation durations

A pre-configured Grafana dashboard is available for visualizing these metrics.