FROM oven/bun:latest as base
WORKDIR /usr/src/app

# Install dependencies for both dev and prod
FROM base as install
RUN mkdir -p /temp/dev
RUN mkdir -p /temp/prod
COPY package.json bun.lockb /temp/dev/
COPY package.json bun.lockb /temp/prod/
RUN cd /temp/dev && bun install --frozen-lockfile
RUN cd /temp/prod && bun install --frozen-lockfile --production

FROM base as build
COPY --from=install /temp/dev/node_modules node_modules
COPY . .
RUN bun --bun vite build 
# THIS BUILD FAILS FOR SOME REASON?!?!?!

FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=build /usr/src/app/build .
USER bun
EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "run", "index.ts" ]


## THIS WORKS THO?
# FROM oven/bun:latest
# WORKDIR /usr/src/app
# COPY . .
# RUN bun install
# RUN bun run build
# EXPOSE 3000
# ENTRYPOINT [ "bun", "./build" ]


# # FROM gplane/pnpm:latest
# # WORKDIR /usr/src/app
# # COPY . .
# # RUN pnpm install
# # RUN pnpm run build
# # EXPOSE 3000
# # ENTRYPOINT [ "node", "./build" ]