# Product definition
public type Product record {|
    int id;
    string name;
    decimal price;
    int stock;
    string category;
|};

# In-memory products database
public Product[] products = [];

# Initialize products data
public function initializeProducts() {
    products = [
        {id: 1, name: "Smartphone", price: 699.99d, stock: 50, category: "Electronics"},
        {id: 2, name: "Laptop", price: 1299.99d, stock: 25, category: "Electronics"},
        {id: 3, name: "Headphones", price: 149.99d, stock: 100, category: "Electronics"},
        {id: 4, name: "Coffee Maker", price: 89.99d, stock: 30, category: "Home Appliances"},
        {id: 5, name: "Running Shoes", price: 79.99d, stock: 45, category: "Sports"}
    ];
}

# Find product by ID
# + id - The product ID to find
# + return - The product if found, otherwise nil
public function findProductById(int id) returns Product? {
    foreach Product product in products {
        if product.id == id {
            return product;
        }
    }
    return ();
}

# Add new product
# + product - The product to add
# + return - The added product
public function addProduct(Product product) returns Product {
    products.push(product);
    return product;
}

# Update product
# + id - The product ID to update
# + updatedProduct - The updated product data
# + return - The updated product if found, otherwise nil
public function updateProduct(int id, Product updatedProduct) returns Product? {
    int? index = ();
    foreach int i in 0 ..< products.length() {
        if products[i].id == id {
            index = i;
            break;
        }
    }
    
    if index is int {
        products[index] = updatedProduct;
        return updatedProduct;
    }
    return ();
}

# Delete product
# + id - The product ID to delete
# + return - True if the product was deleted, otherwise false
public function deleteProduct(int id) returns boolean {
    int? index = ();
    foreach int i in 0 ..< products.length() {
        if products[i].id == id {
            index = i;
            break;
        }
    }
    
    if index is int {
        // Create a new array without the element
        Product[] newProducts = [];
        foreach int i in 0 ..< products.length() {
            if i != index {
                newProducts.push(products[i]);
            }
        }
        products = newProducts;
        return true;
    }
    return false;
}

# Get next product ID
# + return - The next available product ID
public function getNextProductId() returns int {
    int maxId = 0;
    foreach Product product in products {
        if product.id > maxId {
            maxId = product.id;
        }
    }
    return maxId + 1;
}