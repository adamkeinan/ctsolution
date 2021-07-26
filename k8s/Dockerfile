FROM nginx:stable
COPY index2.html /usr/share/nginx/html/index2.html
RUN chmod +r /usr/share/nginx/html/index2.html
COPY default.conf /etc/nginx
COPY nginx.sh /home/nginx.sh
RUN chmod +x /home/nginx.sh
VOLUME /etc/nginx
VOLUME /usr/share/nginx/html
VOLUME /home 
