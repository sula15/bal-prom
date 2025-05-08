import ballerina/http;
import ballerina/time;
import ballerina/lang.'int;
import ecom.api.models;
import ecom.api.metrics;

# Get all orders
# + return - All orders as JSON
public function getAllOrders() returns json {
    time:Seconds startTime = time:currentTime().seconds;
    
    # Track user activity if user info provided
    # In a real implementation, this would come from query params
    
    json result = models:orders.toJson();
    
    # Record DB operation duration
    metrics:recordDbOperationDuration("read", "order", startTime);
    
    return result;
}

# Get order by ID
# + id - The order ID to get
# + return - The order as JSON if found, otherwise a 404 response
public function getOrder(string id) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int orderId = check 'int:fromString(id);
        models:Order? orderObj = models:findOrderById(orderId);
        
        if orderObj is models:Order {
            # Track user activity if user info provided
            # In a real implementation, this would come from query params
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("read", "order", startTime);
            
            return orderObj.toJson();
        } else {
            return createNotFoundResponse("Order not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid order ID: " + e.message());
    }
}

# Create new order
# + payload - The order data
# + return - The created order as JSON, or an error response
public function createOrder(json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        record {
            int userId;
            string? userName;
            record {
                int productId;
                string? productName;
                int quantity;
            }[] products;
            decimal totalAmount;
        } orderData = check payload.cloneWithType();
        
        # Validate request
        if orderData.userId <= 0 || orderData.products.length() == 0 || orderData.totalAmount <= 0d {
            return createBadRequestResponse("Please provide all required fields");
        }
        
        # Enhance products with names (in a real app, you'd look these up)
        models:OrderItem[] enhancedProducts = [];
        foreach var product in orderData.products {
            models:Product? productInfo = models:findProductById(product.productId);
            string productName = product?.productName ?: (productInfo is models:Product ? productInfo.name : "Product " + product.productId.toString());
            
            enhancedProducts.push({
                productId: product.productId,
                productName: productName,
                quantity: product.quantity
            });
        }
        
        # Get or set user name
        string userName = orderData?.userName ?: "User " + orderData.userId.toString();
        
        int newOrderId = models:getNextOrderId();
        models:Order newOrder = {
            id: newOrderId,
            userId: orderData.userId,
            userName: userName,
            products: enhancedProducts,
            totalAmount: orderData.totalAmount,
            status: "Processing",
            createdAt: models:getCurrentTimestamp()
        };
        
        models:addOrder(newOrder);
        
        # Record detailed order metrics
        metrics:incrementOrderPlaced(
            newOrderId.toString(),
            orderData.userId.toString(),
            userName,
            orderData.totalAmount.toString(),
            enhancedProducts.length().toString()
        );
        
        # Record initial order status
        metrics:incrementOrderStatus(
            newOrderId.toString(),
            "Processing"
        );
        
        # Track user activity
        metrics:incrementUserActivity(
            orderData.userId.toString(),
            userName,
            "place_order"
        );
        
        # Record DB operation duration
        metrics:recordDbOperationDuration("create", "order", startTime);
        
        return createCreatedResponse(newOrder.toJson());
    } on fail var e {
        return createBadRequestResponse("Invalid order data: " + e.message());
    }
}

# Update order status
# + id - The order ID to update
# + payload - The status data
# + return - The updated order as JSON, or an error response
public function updateOrderStatus(string id, json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int orderId = check 'int:fromString(id);
        
        record {
            string status;
            int? userId;
            string? userName;
        } statusData = check payload.cloneWithType();
        
        if statusData.status == "" {
            return createBadRequestResponse("Please provide a status");
        }
        
        models:Order? existingOrder = models:findOrderById(orderId);
        if existingOrder is () {
            return createNotFoundResponse("Order not found");
        }
        
        string previousStatus = existingOrder.status;
        models:Order? updatedOrder = models:updateOrderStatus(orderId, statusData.status);
        
        if updatedOrder is models:Order {
            # Record status change metrics
            metrics:incrementOrderStatus(
                orderId.toString(),
                statusData.status
            );
            
            # Track user activity if user info provided
            if statusData?.userId is int {
                metrics:incrementUserActivity(
                    statusData.userId.toString(),
                    statusData?.userName ?: "admin",
                    "update_order_status"
                );
            }
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("update", "order", startTime);
            
            json response = updatedOrder.toJson();
            response = check response.mergeJson({"previousStatus": previousStatus});
            return response;
        } else {
            return createNotFoundResponse("Order status update failed");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid order status data: " + e.message());
    }
}

# Helper functions for HTTP responses
function createNotFoundResponse(string message) returns http:Response {
    http:Response response = new;
    response.statusCode = 404;
    response.setJsonPayload({message: message});
    return response;
}

function createBadRequestResponse(string message) returns http:Response {
    http:Response response = new;
    response.statusCode = 400;
    response.setJsonPayload({message: message});
    return response;
}

function createCreatedResponse(json payload) returns http:Response {
    http:Response response = new;
    response.statusCode = 201;
    response.setJsonPayload(payload);
    return response;
}