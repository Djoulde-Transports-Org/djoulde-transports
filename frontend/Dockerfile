FROM node:22-alpine AS base
WORKDIR /app

# dev — source and node_modules are mounted as volumes; npm ci runs at startup
# so package changes are picked up without rebuilding the image.
FROM base AS dev
EXPOSE 5173
CMD ["sh", "-c", "npm ci && npm run dev -- --host"]

# build — full production compile
FROM base AS build
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
RUN npm run build

# runtime — minimal production image
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3001
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./
RUN npm ci --omit=dev
EXPOSE 3001
CMD ["node", "build"]
