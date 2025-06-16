# Stage 1: Build
FROM node:18-alpine as build
WORKDIR /app

ENV NODE_OPTIONS=--openssl-legacy-provider

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy final build
COPY --from=build /app/build .

#  Inject runtime config 
COPY ./public/config.js ./config.js

#  Custom nginx config to serve app correctly 
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
