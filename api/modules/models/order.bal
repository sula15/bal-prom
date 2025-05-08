import ecom.api.utils;

# Order item definition
public type OrderItem record {|
    int productId;
    string productName;
    int quantity;
|};

# Order definition (using 'Order' with capital O to avoid conflict with 'order' keyword)
public type Order record {|
    int id;
    int userId;
    string userName;
    OrderItem[] products;
    decimal totalAmount;
    string status;
    string createdAt;
|};

# In-memory orders database
public Order[] orders = [];

# Initialize orders data
public function initializeOrders() {
    orders = [
        {
            id: 1,
            userId: 101,
            userName: "Alice Smith",
            products: [
                {productId: 1, productName: "Smartphone", quantity: 2},
                {productId: 3, productName: "Headphones", quantity: 1}
            ],
            totalAmount: 1549.97d,
            status: "Delivered",
            createdAt: "2025-04-25T10:30:00Z"
        },
        {
            id: 2,
            userId: 102,
            userName: "Bob Johnson",
            products: [
                {productId: 2, productName: "Laptop", quantity: 1},
                {productId: 4, productName: "Coffee Maker", quantity: 1}
            ],
            totalAmount: 1389.98d,
            status: "Processing",
            createdAt: "2025-05-01T15:45:00Z"
        }
    ];
}

# Find order by ID
# + id - The order ID to find
# + return - The order if found, otherwise nil
public function findOrderById(int id) returns Order? {
    foreach Order orderObj in orders {
        if orderObj.id == id {
            return orderObj;
        }
    }
    return ();
}

# Add new order
# + orderObj - The order to add
# + return - The added order
public function addOrder(Order orderObj) returns Order {
    orders.push(orderObj);
    return orderObj;
}

# Update order status
# + id - The order ID to update
# + status - The new status
# + return - The updated order if found, otherwise nil
public function updateOrderStatus(int id, string status) returns Order? {
    foreach int i in 0 ..< orders.length() {
        if orders[i].id == id {
            orders[i].status = status;
            return orders[i];
        }
    }
    return ();
}

# Get next order ID
# + return - The next available order ID
public function getNextOrderId() returns int {
    int maxId = 0;
    foreach Order orderObj in orders {
        if orderObj.id > maxId {
            maxId = orderObj.id;
        }
    }
    return maxId + 1;
}

# Get current timestamp
# + return - The current timestamp as an ISO string
public function getCurrentTimestamp() returns string {
    return utils:getCurrentTimestamp();
}