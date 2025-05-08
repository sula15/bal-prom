import ballerina/http;
import ballerina/time;
import ballerina/lang.'int;
import ecom.api.models;
import ecom.api.metrics;

# Get all products
# + return - All products as JSON
public function getAllProducts() returns json {
    time:Seconds startTime = time:currentTime().seconds;
    
    # Record user activity if userID is provided in query params
    # In a real implementation, this would come from query params
    
    json result = models:products.toJson();
    
    # Record DB operation duration
    metrics:recordDbOperationDuration("read", "product", startTime);
    
    return result;
}

# Get product by ID
# + id - The product ID to get
# + return - The product as JSON if found, otherwise a 404 response
public function getProduct(string id) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int productId = check 'int:fromString(id);
        models:Product? product = models:findProductById(productId);
        
        if product is models:Product {
            # Record product view with product details for analytics
            metrics:incrementProductViews(
                productId.toString(), 
                product.name, 
                product.category, 
                product.price.toString()
            );
            
            # Record user activity if user info provided
            # In a real implementation, this would come from query params
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("read", "product", startTime);
            
            return product.toJson();
        } else {
            return createNotFoundResponse("Product not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid product ID: " + e.message());
    }
}

# Create new product
# + payload - The product data
# + return - The created product as JSON, or an error response
public function createProduct(json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        record {
            string name;
            decimal price;
            int stock;
            string category;
        } productData = check payload.cloneWithType();
        
        # Validate request
        if productData.name == "" || productData.price <= 0d || productData.stock < 0 || productData.category == "" {
            return createBadRequestResponse("Please provide all required fields");
        }
        
        int newId = models:getNextProductId();
        models:Product newProduct = {
            id: newId,
            name: productData.name,
            price: productData.price,
            stock: productData.stock,
            category: productData.category
        };
        
        models:addProduct(newProduct);
        
        # Increment product creation counter with product details
        metrics:incrementProductCreation(
            newId.toString(),
            newProduct.name,
            newProduct.category,
            newProduct.price.toString()
        );
        
        # Record user activity if user info provided
        # In a real implementation, this would come from the request body
        
        # Record DB operation duration
        metrics:recordDbOperationDuration("create", "product", startTime);
        
        return createCreatedResponse(newProduct.toJson());
    } on fail var e {
        return createBadRequestResponse("Invalid product data: " + e.message());
    }
}

# Update product
# + id - The product ID to update
# + payload - The updated product data
# + return - The updated product as JSON, or an error response
public function updateProduct(string id, json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int productId = check 'int:fromString(id);
        models:Product? existingProduct = models:findProductById(productId);
        
        if existingProduct is () {
            return createNotFoundResponse("Product not found");
        }
        
        record {
            string? name;
            decimal? price;
            int? stock;
            string? category;
        } productData = check payload.cloneWithType();
        
        models:Product updatedProduct = {
            id: productId,
            name: productData.name ?: existingProduct.name,
            price: productData.price ?: existingProduct.price,
            stock: productData.stock ?: existingProduct.stock,
            category: productData.category ?: existingProduct.category
        };
        
        models:Product? result = models:updateProduct(productId, updatedProduct);
        
        if result is models:Product {
            # Record user activity if user info provided
            # In a real implementation, this would come from request body
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("update", "product", startTime);
            
            return result.toJson();
        } else {
            return createNotFoundResponse("Product update failed");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid product data: " + e.message());
    }
}

# Delete product
# + id - The product ID to delete
# + return - A 204 response if deleted, otherwise an error response
public function deleteProduct(string id) returns http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int productId = check 'int:fromString(id);
        boolean deleted = models:deleteProduct(productId);
        
        if deleted {
            # Record user activity if user info provided
            # In a real implementation, this would come from query params
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("delete", "product", startTime);
            
            return createNoContentResponse();
        } else {
            return createNotFoundResponse("Product not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid product ID: " + e.message());
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

function createNoContentResponse() returns http:Response {
    http:Response response = new;
    response.statusCode = 204;
    return response;
}