# Bulider target
FROM public.ecr.aws/n1w1r2j5/docker-images:node.16.13.1-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git build-base make bash tini

# Securely create app directory owned by node
RUN install -d -o node -g node /home/node/app

# Set non-root user & working directory
USER node
WORKDIR /home/node/app

# Set npm cache to a location writable by node
ENV NPM_CONFIG_CACHE=/home/node/.npm-cache

# Copy package.json first for caching
COPY --chown=node:node package.json ./

# Increase memory limit if needed
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Install dependencies
RUN npm install

# Copy source code
COPY --chown=node:node . .

# Create dist for code build with proper permissions
RUN rm -rf ./dist && mkdir ./dist

# Build the project
RUN make make-build

# Production target
FROM public.ecr.aws/n1w1r2j5/docker-images:node.16.13.1-alpine AS production

# Install runtime dependencies only
RUN apk add --no-cache make tini bash

# Create non-root user (same user and group name)
RUN addgroup -S appgroup && adduser -S produser -G appgroup

# Securely create app directory owned by produser
RUN install -d -o produser -g appgroup /home/node/app

# Set non-root user & working directory
USER produser
WORKDIR /home/node/app

# Copy built app from builder
COPY --from=builder /home/node/app/package*.json ./
COPY --from=builder /home/node/app/node_modules ./node_modules
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/Makefile ./
COPY --from=builder /home/node/app/.sequelizerc_prod ./


RUN mv ./.sequelizerc_prod ./.sequelizerc

# Expose ports
ENV NODE_ENV=production
EXPOSE 80

# Use Tini as init system
ENTRYPOINT ["/sbin/tini", "--"]

# Start the app
CMD ["npm", "run", "start"]
