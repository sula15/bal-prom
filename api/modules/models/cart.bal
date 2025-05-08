import ecom.api.utils;

# Cart item definition
public type CartItem record {|
    int productId;
    int quantity;
|};

# Cart definition
public type Cart record {|
    int id;
    int userId;
    CartItem[] products;
    string lastUpdated;
|};

# In-memory carts database
public Cart[] carts = [];

# Initialize carts data
public function initializeCarts() {
    carts = [
        {
            id: 1,
            userId: 101,
            products: [
                {productId: 1, quantity: 1},
                {productId: 3, quantity: 2}
            ],
            lastUpdated: "2025-05-03T09:15:00Z"
        },
        {
            id: 2,
            userId: 102,
            products: [
                {productId: 2, quantity: 1}
            ],
            lastUpdated: "2025-05-04T14:30:00Z"
        }
    ];
}

# Find cart by user ID
# + userId - The user ID to find
# + return - The cart if found, otherwise nil
public function findCartByUserId(int userId) returns Cart? {
    foreach Cart cart in carts {
        if cart.userId == userId {
            return cart;
        }
    }
    return ();
}

# Create or update cart
# + userId - The user ID
# + products - The cart products
# + return - The updated or created cart
public function createOrUpdateCart(int userId, CartItem[] products) returns Cart {
    Cart? existingCart = findCartByUserId(userId);
    
    if existingCart is Cart {
        foreach int i in 0 ..< carts.length() {
            if carts[i].userId == userId {
                carts[i].products = products;
                carts[i].lastUpdated = getCurrentTimestamp();
                return carts[i];
            }
        }
    }
    
    # Create new cart if not found
    Cart newCart = {
        id: getNextCartId(),
        userId: userId,
        products: products,
        lastUpdated: getCurrentTimestamp()
    };
    
    carts.push(newCart);
    return newCart;
}

# Add product to cart
# + userId - The user ID
# + productId - The product ID to add
# + quantity - The quantity to add
# + return - The updated cart
public function addProductToCart(int userId, int productId, int quantity) returns Cart {
    Cart? existingCart = findCartByUserId(userId);
    
    if existingCart is Cart {
        boolean productExists = false;
        
        foreach int i in 0 ..< carts.length() {
            if carts[i].userId == userId {
                foreach int j in 0 ..< carts[i].products.length() {
                    if carts[i].products[j].productId == productId {
                        carts[i].products[j].quantity += quantity;
                        productExists = true;
                        break;
                    }
                }
                
                if !productExists {
                    carts[i].products.push({productId: productId, quantity: quantity});
                }
                
                carts[i].lastUpdated = getCurrentTimestamp();
                return carts[i];
            }
        }
    }
    
    # Create new cart if not found
    Cart newCart = {
        id: getNextCartId(),
        userId: userId,
        products: [{productId: productId, quantity: quantity}],
        lastUpdated: getCurrentTimestamp()
    };
    
    carts.push(newCart);
    return newCart;
}

# Remove product from cart
# + userId - The user ID
# + productId - The product ID to remove
# + return - The updated cart if found, otherwise nil
public function removeProductFromCart(int userId, int productId) returns Cart? {
    foreach int i in 0 ..< carts.length() {
        if carts[i].userId == userId {
            CartItem[] updatedProducts = [];
            
            foreach CartItem item in carts[i].products {
                if item.productId != productId {
                    updatedProducts.push(item);
                }
            }
            
            carts[i].products = updatedProducts;
            carts[i].lastUpdated = getCurrentTimestamp();
            return carts[i];
        }
    }
    
    return ();
}

# Clear cart
# + userId - The user ID
# + return - True if the cart was cleared, otherwise false
public function clearCart(int userId) returns boolean {
    foreach int i in 0 ..< carts.length() {
        if carts[i].userId == userId {
            carts[i].products = [];
            carts[i].lastUpdated = getCurrentTimestamp();
            return true;
        }
    }
    
    return false;
}

# Get next cart ID
# + return - The next available cart ID
public function getNextCartId() returns int {
    int maxId = 0;
    foreach Cart cart in carts {
        if cart.id > maxId {
            maxId = cart.id;
        }
    }
    return maxId + 1;
}

# Get timestamp from utils module
# + return - The current timestamp as an ISO string
public function getCurrentTimestamp() returns string {
    return utils:getCurrentTimestamp();
}