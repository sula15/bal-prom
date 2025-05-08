# Dockerfile for the Ballerina e-commerce API
FROM ballerina/ballerina:2201.8.0

WORKDIR /app

# Copy the project files
COPY . /app

# Build the Ballerina project
RUN bal build

# Expose the API port
EXPOSE 3000

# Start the app
CMD ["bal", "run", "target/bin/e_commerce_bal.jar"]