FROM php:8.2-apache

ARG upload_max_filesize=1G

COPY src/ /var/www/html/

# 1. Set /var/www/html permissions
# 2. Install shimmie dependencies
# 3. Enable apache modules required by .htaccess
# 4. Configure php.ini

RUN apt-get update && \
	apt-get install --no-install-recommends -y imagemagick ffmpeg

RUN chmod -R 777 /var/www/html && \
	a2enmod dir rewrite expires headers deflate && \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
	echo "upload_max_filesize = ${upload_max_filesize}" \
	> "$PHP_INI_DIR/conf.d/upload-max-filesize.ini" && \
	echo "post_max_size = ${upload_max_filesize}" \
	>> "$PHP_INI_DIR/conf.d/upload-max-filesize.ini"

# The php:apache image by default enables `AllowOverride all` (allowing
# use of .htaccess files)
