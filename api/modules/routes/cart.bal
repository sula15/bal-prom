import ballerina/http;
import ballerina/time;
import ballerina/lang.'int;
import ecom.api.models;
import ecom.api.metrics;

# Get cart by user ID
# + userId - The user ID to get the cart for
# + return - The cart as JSON if found, otherwise a 404 response
public function getCart(string userId) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userIdInt = check 'int:fromString(userId);
        models:Cart? cart = models:findCartByUserId(userIdInt);
        
        if cart is models:Cart {
            # Record DB operation duration
            metrics:recordDbOperationDuration("read", "cart", startTime);
            
            return cart.toJson();
        } else {
            return createNotFoundResponse("Cart not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid user ID: " + e.message());
    }
}

# Create or update cart
# + userId - The user ID to update the cart for
# + payload - The cart data
# + return - The updated cart as JSON, or an error response
public function updateCart(string userId, json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userIdInt = check 'int:fromString(userId);
        
        record {
            models:CartItem[] products;
        } cartData = check payload.cloneWithType();
        
        if cartData.products.length() == 0 {
            return createBadRequestResponse("Please provide a valid products array");
        }
        
        models:Cart cart = models:createOrUpdateCart(userIdInt, cartData.products);
        
        # Record DB operation duration
        models:Cart? existingCart = models:findCartByUserId(userIdInt);
        string operation = existingCart is models:Cart ? "update" : "create";
        metrics:recordDbOperationDuration(operation, "cart", startTime);
        
        if operation == "create" {
            return createCreatedResponse(cart.toJson());
        } else {
            return cart.toJson();
        }
    } on fail var e {
        return createBadRequestResponse("Invalid cart data: " + e.message());
    }
}

# Add product to cart
# + userId - The user ID to add the product to
# + payload - The product data
# + return - The updated cart as JSON, or an error response
public function addProductToCart(string userId, json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userIdInt = check 'int:fromString(userId);
        
        record {
            int productId;
            int? quantity;
        } productData = check payload.cloneWithType();
        
        if productData.productId <= 0 {
            return createBadRequestResponse("Please provide a valid productId");
        }
        
        int quantity = productData?.quantity ?: 1;
        models:Cart cart = models:addProductToCart(userIdInt, productData.productId, quantity);
        
        # Record cart operation metrics
        models:Product? product = models:findProductById(productData.productId);
        string productName = product is models:Product ? product.name : "Product " + productData.productId.toString();
        
        metrics:incrementCartOperation(
            userIdInt.toString(),
            productData.productId.toString(),
            productName,
            "add"
        );
        
        # Record DB operation duration
        boolean isNewCart = models:findCartByUserId(userIdInt) is ();
        string operation = isNewCart ? "create" : "update";
        metrics:recordDbOperationDuration(operation, "cart", startTime);
        
        return cart.toJson();
    } on fail var e {
        return createBadRequestResponse("Invalid product data: " + e.message());
    }
}

# Remove product from cart
# + userId - The user ID to remove the product from
# + productId - The product ID to remove
# + return - The updated cart as JSON, or an error response
public function removeProductFromCart(string userId, string productId) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userIdInt = check 'int:fromString(userId);
        int productIdInt = check 'int:fromString(productId);
        
        models:Cart? updatedCart = models:removeProductFromCart(userIdInt, productIdInt);
        
        if updatedCart is models:Cart {
            # Record cart operation metrics
            models:Product? product = models:findProductById(productIdInt);
            string productName = product is models:Product ? product.name : "Product " + productIdInt.toString();
            
            metrics:incrementCartOperation(
                userIdInt.toString(),
                productIdInt.toString(),
                productName,
                "remove"
            );
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("update", "cart", startTime);
            
            return updatedCart.toJson();
        } else {
            return createNotFoundResponse("Cart not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid user or product ID: " + e.message());
    }
}

# Clear cart
# + userId - The user ID to clear the cart for
# + return - A success response if cleared, otherwise an error response
public function clearCart(string userId) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userIdInt = check 'int:fromString(userId);
        boolean cleared = models:clearCart(userIdInt);
        
        if cleared {
            # Record DB operation duration
            metrics:recordDbOperationDuration("update", "cart", startTime);
            
            return {message: "Cart cleared successfully"};
        } else {
            return createNotFoundResponse("Cart not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid user ID: " + e.message());
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