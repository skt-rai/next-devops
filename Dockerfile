# 外部イメージをbaseステージとして扱う
FROM node:18-alpine AS base

# Builder Stage
# baseステージをもとにbuilderステージを開始
FROM base AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

RUN npm run build

# Production Stage 
# baseステージをもとにrunnerステージを開始
FROM base AS runner

WORKDIR /app

# .next/standalone と .next/static は nextjs の standalone を使う場合に含まれないため、コピーする必要がある
# https://nextjs.org/docs/advanced-features/output-file-tracing#automatically-copying-traced-files
# builderから必要なファイルだけコピーする
# Copy the built artifacts from the builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Set the environment variables (if needed)
ENV NODE_ENV=production

EXPOSE 3000

# `next start` の代わりに `node server.js` を使用
# https://nextjs.org/docs/advanced-features/output-file-tracing#automatically-copying-traced-files
CMD ["node", "server.js"]