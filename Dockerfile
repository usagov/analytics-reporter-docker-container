FROM node:18-alpine
USER root
COPY . .
RUN chmod +x /testscript.sh
RUN apk add jq
RUN apk add bash
CMD ["./testscript.sh"]