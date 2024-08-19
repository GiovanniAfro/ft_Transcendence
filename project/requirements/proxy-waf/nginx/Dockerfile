# FROM owasp/modsecurity-crs:nginx

FROM nginx:stable-perl

COPY --chown=nginx:nginx conf/ft_transcendence.conf /etc/nginx/conf.d/ft_transcendence.conf

RUN rm -rf /etc/nginx/conf.d/*

