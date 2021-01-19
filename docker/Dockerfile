FROM node:13-buster AS builder

COPY . /app

WORKDIR /app

RUN apt update && apt install libncurses5 -y

RUN rm -rf node_modules/ && \
    npm install && \
    npx spago bundle-app --to Main.js

FROM node:13-buster-slim

COPY --from=builder /app /app

WORKDIR /app

ENTRYPOINT [ "node" , "Main.js"]
