import ballerina/http;
import ballerina/time;
import ballerina/lang.'int;
import ecom.api.models;
import ecom.api.metrics;

# Get all users
# + return - All users as JSON
public function getAllUsers() returns json {
    time:Seconds startTime = time:currentTime().seconds;
    
    # Only return non-sensitive info
    json[] safeUsers = [];
    foreach models:User user in models:users {
        safeUsers.push({
            id: user.id,
            name: user.name,
            role: user.role,
            active: user.active
        });
    }
    
    # Record DB operation duration
    metrics:recordDbOperationDuration("read", "user", startTime);
    
    return safeUsers.toJson();
}

# Get user by ID
# + id - The user ID to get
# + return - The user as JSON if found, otherwise a 404 response
public function getUser(string id) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userId = check 'int:fromString(id);
        models:User? user = models:findUserById(userId);
        
        if user is models:User {
            # Only return non-sensitive info
            json safeUser = {
                id: user.id,
                name: user.name,
                role: user.role,
                active: user.active
            };
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("read", "user", startTime);
            
            return safeUser;
        } else {
            return createNotFoundResponse("User not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid user ID: " + e.message());
    }
}

# Create new user
# + payload - The user data
# + return - The created user as JSON, or an error response
public function createUser(json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        record {
            string name;
            string email;
            string? role;
        } userData = check payload.cloneWithType();
        
        # Validate request
        if userData.name == "" || userData.email == "" {
            return createBadRequestResponse("Please provide name and email");
        }
        
        # Check if email already exists
        models:User? existingUser = models:findUserByEmail(userData.email);
        if existingUser is models:User {
            return createConflictResponse("Email already exists");
        }
        
        int newUserId = models:getNextUserId();
        models:User newUser = {
            id: newUserId,
            name: userData.name,
            email: userData.email,
            role: userData?.role ?: "customer",
            active: true
        };
        
        models:addUser(newUser);
        
        # Update active users count
        int activeUsers = models:getActiveUserCount();
        metrics:setActiveUsers(<float>activeUsers);
        
        # Record DB operation duration
        metrics:recordDbOperationDuration("create", "user", startTime);
        
        # Only return non-sensitive info
        json safeUser = {
            id: newUser.id,
            name: newUser.name,
            role: newUser.role,
            active: newUser.active
        };
        
        return createCreatedResponse(safeUser);
    } on fail var e {
        return createBadRequestResponse("Invalid user data: " + e.message());
    }
}

# Update user
# + id - The user ID to update
# + payload - The updated user data
# + return - The updated user as JSON, or an error response
public function updateUser(string id, json payload) returns json|http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userId = check 'int:fromString(id);
        models:User? existingUser = models:findUserById(userId);
        
        if existingUser is () {
            return createNotFoundResponse("User not found");
        }
        
        record {
            string? name;
            string? email;
            string? role;
        } userData = check payload.cloneWithType();
        
        # Check if email already exists and is not this user's
        if userData?.email is string && userData.email != existingUser.email {
            models:User? emailUser = models:findUserByEmail(userData.email);
            if emailUser is models:User {
                return createConflictResponse("Email already exists");
            }
        }
        
        models:User updatedUser = {
            id: userId,
            name: userData?.name ?: existingUser.name,
            email: userData?.email ?: existingUser.email,
            role: userData?.role ?: existingUser.role,
            active: existingUser.active
        };
        
        models:User? result = models:updateUser(userId, updatedUser);
        
        if result is models:User {
            # Record DB operation duration
            metrics:recordDbOperationDuration("update", "user", startTime);
            
            # Only return non-sensitive info
            json safeUser = {
                id: result.id,
                name: result.name,
                role: result.role,
                active: result.active
            };
            
            return safeUser;
        } else {
            return createNotFoundResponse("User update failed");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid user data: " + e.message());
    }
}

# Deactivate user (soft delete)
# + id - The user ID to deactivate
# + return - A success response if deactivated, otherwise an error response
public function deactivateUser(string id) returns http:Response {
    time:Seconds startTime = time:currentTime().seconds;
    
    do {
        int userId = check 'int:fromString(id);
        boolean deactivated = models:deactivateUser(userId);
        
        if deactivated {
            # Update active users count
            int activeUsers = models:getActiveUserCount();
            metrics:setActiveUsers(<float>activeUsers);
            
            # Record DB operation duration
            metrics:recordDbOperationDuration("update", "user", startTime);
            
            http:Response response = new;
            response.statusCode = 200;
            response.setJsonPayload({message: "User deactivated successfully"});
            return response;
        } else {
            return createNotFoundResponse("User not found");
        }
    } on fail var e {
        return createBadRequestResponse("Invalid user ID: " + e.message());
    }
}

# Additional HTTP response helpers
function createConflictResponse(string message) returns http:Response {
    http:Response response = new;
    response.statusCode = 409;
    response.setJsonPayload({message: message});
    return response;
}

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