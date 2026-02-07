FROM node:24-alpine
WORKDIR /app
RUN npm install -g @upstash/context7-mcp
ENTRYPOINT ["context7-mcp"]
