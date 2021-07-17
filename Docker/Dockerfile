FROM node:14.17.3-alpine3.14
ENV NODE_ENV=production
WORKDIR /weather-api
COPY /weather-api/package.json /weather-api/
COPY /weather-api/package-lock.json /weather-api/
USER node
RUN npm install
COPY . /weather-api
EXPOSE 3005
ENV PORT 8088
CMD node npm-start