FROM node:22.22-alpine3.22 AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci

FROM build AS test
COPY . .
RUN npm test

FROM node:22.22-alpine3.22
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=test /app/node_modules ./node_modules
COPY --from=test /app/package.json ./
COPY --from=test /app/bin ./bin
COPY --from=test /app/app.js ./
USER appuser
EXPOSE 3000
CMD ["node", "./bin/www"]
