import ballerina/observe;
import ballerina/time;

# Product metrics
public final observe:Counter productViewsCounter = new("ecommerce_product_views_total", 
    "Total number of product views", 
    ["product_id", "product_name", "category", "price"]);

public final observe:Counter productCreationCounter = new("ecommerce_product_creations_total", 
    "Total number of products created", 
    ["product_id", "product_name", "category", "price"]);

# Order metrics
public final observe:Counter orderPlacedCounter = new("ecommerce_order_placed_total", 
    "Total number of orders placed", 
    ["order_id", "user_id", "user_name", "total_amount", "product_count"]);

public final observe:Counter orderStatusCounter = new("ecommerce_order_status_total", 
    "Count of orders by status", 
    ["order_id", "status"]);

# User metrics
public final observe:Counter userActivityCounter = new("ecommerce_user_activity_total", 
    "Total activities by users", 
    ["user_id", "user_name", "activity_type"]);

public final observe:Gauge activeUsersGauge = new("ecommerce_active_users", 
    "Number of active users");

# Cart metrics
public final observe:Counter cartOperationsCounter = new("ecommerce_cart_operations_total", 
    "Cart operations (add/remove)", 
    ["user_id", "product_id", "product_name", "operation"]);

# Database operation metrics
public final observe:Histogram dbOperationDurationHistogram = new("ecommerce_db_operation_duration_seconds", 
    "Duration of database operations in seconds", 
    ["operation", "entity"], 
    [0.01, 0.05, 0.1, 0.5, 1, 2, 5]);

# Functions to record metrics
# + operation - The database operation type (read, create, update, delete)
# + entity - The entity being operated on (product, order, user, cart)
# + startTime - The start time of the operation
public function recordDbOperationDuration(string operation, string entity, time:Seconds startTime) {
    time:Seconds endTime = time:currentTime().seconds;
    float duration = <float>(endTime - startTime);
    dbOperationDurationHistogram.record(duration, [operation, entity]);
}

# + productId - The product ID
# + productName - The product name
# + category - The product category
# + price - The product price
public function incrementProductViews(string productId, string productName, string category, string price) {
    productViewsCounter.increment(1, [productId, productName, category, price]);
}

# + productId - The product ID
# + productName - The product name
# + category - The product category
# + price - The product price
public function incrementProductCreation(string productId, string productName, string category, string price) {
    productCreationCounter.increment(1, [productId, productName, category, price]);
}

# + orderId - The order ID
# + userId - The user ID
# + userName - The user name
# + totalAmount - The total amount of the order
# + productCount - The number of products in the order
public function incrementOrderPlaced(string orderId, string userId, string userName, string totalAmount, string productCount) {
    orderPlacedCounter.increment(1, [orderId, userId, userName, totalAmount, productCount]);
}

# + orderId - The order ID
# + status - The order status
public function incrementOrderStatus(string orderId, string status) {
    orderStatusCounter.increment(1, [orderId, status]);
}

# + userId - The user ID
# + userName - The user name
# + activityType - The activity type
public function incrementUserActivity(string userId, string userName, string activityType) {
    userActivityCounter.increment(1, [userId, userName, activityType]);
}

# + userId - The user ID
# + productId - The product ID
# + productName - The product name
# + operation - The operation (add, remove)
public function incrementCartOperation(string userId, string productId, string productName, string operation) {
    cartOperationsCounter.increment(1, [userId, productId, productName, operation]);
}

# + count - The number of active users
public function setActiveUsers(float count) {
    activeUsersGauge.setValue(count);
}