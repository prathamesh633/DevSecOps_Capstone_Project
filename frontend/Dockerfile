FROM node:18-alpine

WORKDIR /app

COPY package.json .
COPY package-lock.json .
RUN npm install

COPY . .

# Checkov CKV_DOCKER_3: Use non-root user (node is pre-created in the node image)
RUN chown -R node:node /app
USER node

# Checkov CKV_DOCKER_2: Add HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

CMD ["npm", "start"]
