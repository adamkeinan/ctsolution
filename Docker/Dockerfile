FROM node:14.7-alpine3.14
ENV NODE_ENV=production
WORKDIR /weather-app
COPY package.json /weather-app
COPY package-lock.json /weather-app
USER node
RUN npm install
COPY . /weather-app
EXPOSE 3005
ENV PORT 8088
CMD node npm-start