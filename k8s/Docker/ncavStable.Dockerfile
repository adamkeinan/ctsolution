FROM nginx:stable
COPY index2.html /usr/share/nginx/html/index2.html
RUN chmod +r /usr/share/nginx/html/index2.html
COPY conf /etc/nginx
COPY auto-reload-nginx.sh /home/auto-reload-nginx.sh
RUN chmod +x /home/auto-reload-nginx.sh
VOLUME /usr/share/nginx/html
VOLUME /etc/nginx
# install inotify
RUN apt-get update && apt-get install -y inotify-tools