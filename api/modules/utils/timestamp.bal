import ballerina/time;

# Current timestamp formatted as ISO string
# 
# + return - The current timestamp as an ISO string
public function getCurrentTimestamp() returns string {
    time:Utc currentTime = time:utcNow();
    return currentTime.toString();
}