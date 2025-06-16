# Backend Dockerfile for Express + DynamoDB
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Expose backend port
EXPOSE 3001

# Start backend server
CMD ["npm", "start"]
