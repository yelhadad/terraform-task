FROM nginx:latest
WORKDIR /nginx-reverse-proxy
COPY ./ ./
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf