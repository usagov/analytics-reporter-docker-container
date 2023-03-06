FROM node:18-alpine
USER root
COPY . .
RUN chmod +x /createreports.sh
RUN apk add jq
RUN apk add bash
CMD ["./createreports.sh"]