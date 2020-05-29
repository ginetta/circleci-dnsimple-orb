FROM node:dubnium-alpine

ENV NODE_ENV="production"
ENV PORT=3000

WORKDIR /usr/src/website
ADD . .

EXPOSE ${PORT}

CMD ["npm","start"]
