# Use a multi-stage build so the final image only contains the runtime output
FROM node:20-alpine AS deps
WORKDIR /app

# Install dependencies as a separate layer to leverage Docker cache
COPY package.json package-lock.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/standalone ./standalone

EXPOSE 3000
CMD ["node", "standalone/server.js"]
