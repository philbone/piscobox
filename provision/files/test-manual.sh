#!/bin/bash

SCRIPT_FILENAME=/var/www/html/hola.php \
REQUEST_METHOD=GET \
cgi-fcgi -bind -connect /run/php/php-default-fpm.sock