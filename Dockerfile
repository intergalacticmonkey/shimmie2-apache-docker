FROM php:8.2-apache

ENV UPLOAD_MAX_FILESIZE 1G

COPY src/ /var/www/html/

# 1. Set /var/www/html permissions
# 2. Install shimmie dependencies
# 3. Enable apache modules required by .htaccess
# 4. Configure php.ini

RUN chmod -R 777 /var/www/html && \
	apt-get update && \
	apt-get install --no-install-recommends -y imagemagick ffmpeg && \
	a2enmod dir rewrite expires headers deflate && \
	mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
	echo "upload_max_filesize = ${UPLOAD_MAX_FILESIZE}" \
	> "$PHP_INI_DIR/conf.d/upload-max-filesize.ini"

# The php:apache image by default enables `AllowOverride all` (allowing
# use of .htaccess files)