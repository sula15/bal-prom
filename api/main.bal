import ballerina/http;
import ballerina/log;
import ballerinax/prometheus as _;
import ecom.api.models;
import ecom.api.routes;

# Enable metrics
configurable int port = 3000;

# Main service
service / on new http:Listener(port) {
    # Initialize data
    function init() {
        models:initializeData();
    }

    # Health check endpoint
    resource function get health() returns json {
        return { status: "ok" };
    }

    # Root endpoint
    resource function get .() returns json {
        return {
            message: "E-commerce API is running",
            endpoints: {
                metrics: "/metrics",
                health: "/health",
                products: "/api/products",
                orders: "/api/orders",
                users: "/api/users",
                cart: "/api/cart"
            }
        };
    }

    # Metrics endpoint provided by Prometheus package

    # API Routes
    resource function get api/products/[string id]() returns json|http:Response {
        return routes:getProduct(id);
    }

    resource function get api/products() returns json {
        return routes:getAllProducts();
    }

    resource function post api/products(json payload) returns json|http:Response {
        return routes:createProduct(payload);
    }

    resource function put api/products/[string id](json payload) returns json|http:Response {
        return routes:updateProduct(id, payload);
    }

    resource function delete api/products/[string id]() returns http:Response {
        return routes:deleteProduct(id);
    }

    # Order routes
    resource function get api/orders/[string id]() returns json|http:Response {
        return routes:getOrder(id);
    }

    resource function get api/orders() returns json {
        return routes:getAllOrders();
    }

    resource function post api/orders(json payload) returns json|http:Response {
        return routes:createOrder(payload);
    }

    resource function patch api/orders/[string id]/status(json payload) returns json|http:Response {
        return routes:updateOrderStatus(id, payload);
    }

    # User routes
    resource function get api/users/[string id]() returns json|http:Response {
        return routes:getUser(id);
    }

    resource function get api/users() returns json {
        return routes:getAllUsers();
    }

    resource function post api/users(json payload) returns json|http:Response {
        return routes:createUser(payload);
    }

    resource function put api/users/[string id](json payload) returns json|http:Response {
        return routes:updateUser(id, payload);
    }

    resource function delete api/users/[string id]() returns http:Response {
        return routes:deactivateUser(id);
    }

    # Cart routes
    resource function get api/cart/user/[string userId]() returns json|http:Response {
        return routes:getCart(userId);
    }

    resource function post api/cart/user/[string userId](json payload) returns json|http:Response {
        return routes:updateCart(userId, payload);
    }

    resource function post api/cart/user/[string userId]/product(json payload) returns json|http:Response {
        return routes:addProductToCart(userId, payload);
    }

    resource function delete api/cart/user/[string userId]/product/[string productId]() returns json|http:Response {
        return routes:removeProductFromCart(userId, productId);
    }

    resource function delete api/cart/user/[string userId]() returns json|http:Response {
        return routes:clearCart(userId);
    }
}

public function main() {
    log:printInfo("E-commerce API started on port " + port.toString());
}