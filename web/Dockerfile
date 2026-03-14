# Build phase
FROM node:22.22-alpine3.22 AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci

# Always test before build
FROM build AS test
COPY . .
RUN npm test

# Final Image
FROM node:22.22-alpine3.22 AS prod
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=test /app/node_modules ./node_modules
COPY --from=test /app/package.json ./
COPY --from=test /app/bin ./bin
COPY --from=test /app/app.js ./
COPY --from=test /app/routes ./routes
COPY --from=test /app/views ./views
COPY --from=test /app/public ./public

USER appuser

EXPOSE 3000
CMD ["node", "./bin/www"]
