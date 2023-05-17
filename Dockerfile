FROM node:18-alpine
USER root
COPY . .
RUN chmod +x /createreport.sh
RUN apk add jq
RUN apk add bash
CMD ["./createreport.sh"]