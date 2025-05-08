# User definition
public type User record {|
    int id;
    string name;
    string email;
    string role;
    boolean active;
|};

# In-memory users database
public User[] users = [];

# Initialize users data
public function initializeUsers() {
    users = [
        {id: 101, name: "Alice Smith", email: "alice@example.com", role: "customer", active: true},
        {id: 102, name: "Bob Johnson", email: "bob@example.com", role: "customer", active: true},
        {id: 103, name: "Charlie Brown", email: "charlie@example.com", role: "admin", active: true}
    ];
}

# Find user by ID
# + id - The user ID to find
# + return - The user if found, otherwise nil
public function findUserById(int id) returns User? {
    foreach User user in users {
        if user.id == id {
            return user;
        }
    }
    return ();
}

# Find user by email
# + email - The email to find
# + return - The user if found, otherwise nil
public function findUserByEmail(string email) returns User? {
    foreach User user in users {
        if user.email == email {
            return user;
        }
    }
    return ();
}

# Add new user
# + user - The user to add
# + return - The added user
public function addUser(User user) returns User {
    users.push(user);
    return user;
}

# Update user
# + id - The user ID to update
# + updatedUser - The updated user data
# + return - The updated user if found, otherwise nil
public function updateUser(int id, User updatedUser) returns User? {
    foreach int i in 0 ..< users.length() {
        if users[i].id == id {
            users[i] = updatedUser;
            return updatedUser;
        }
    }
    return ();
}

# Deactivate user (soft delete)
# + id - The user ID to deactivate
# + return - True if the user was deactivated, otherwise false
public function deactivateUser(int id) returns boolean {
    foreach int i in 0 ..< users.length() {
        if users[i].id == id {
            users[i].active = false;
            return true;
        }
    }
    return false;
}

# Get next user ID
# + return - The next available user ID
public function getNextUserId() returns int {
    int maxId = 0;
    foreach User user in users {
        if user.id > maxId {
            maxId = user.id;
        }
    }
    return maxId + 1;
}

# Get count of active users
# + return - The number of active users
public function getActiveUserCount() returns int {
    int count = 0;
    foreach User user in users {
        if user.active {
            count += 1;
        }
    }
    return count;
}