FROM node:20-alpine AS builder
WORKDIR /app

RUN apk add --no-cache python3 make g++

ENV NODE_ENV=development

COPY package*.json ./
RUN npm ci

COPY tsconfig*.json ./
COPY src ./src
RUN npm run build

RUN npm prune --omit=dev


FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

USER node

COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/dist ./dist
COPY --chown=node:node package*.json ./

EXPOSE 3000
CMD ["node", "dist/main.js"]
