FROM node:16.16 AS builder

WORKDIR /app
# RUN apt-get update 
COPY package*.json ./

# Tell Puppeteer to skip installing Chrome
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN npm install --no-audit
COPY . .
#RUN npm run update-models
RUN npm run build

FROM node:16.16-alpine AS release

WORKDIR /app
COPY package*.json ./
COPY . .

# install chromium and dependecies
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn


# Tell Puppeteer to skip installing chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

COPY --from=builder /app/dist ./dist

RUN npm install --omit=dev --no-audit

CMD npm run start:server
