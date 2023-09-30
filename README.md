# Simple Apache Dockerfile for Shimmie2

This is a simple Dockerfile which builds a [Shimmie2](https://github.com/shish/shimmie2) + PHP + Apache + SQLite container. It's based on the [official PHP Docker image](https://hub.docker.com/_/php), which itself is based on Debian.

## Usage

Download a compiled version of Shimmie from the [GitHub releases](https://github.com/shish/shimmie2/releases), or compile it yourself. Place Shimmie into a directory called `src/`.

NOTE: The `.htaccess` file included with the Shimmie 2.9.3 release is broken. Replace it with the latest version from the main branch: https://github.com/shish/shimmie2/blob/main/.htaccess

Build the Dockerfile (`src/`, relative to the current directory, must contain a compiled Shimmie):

```
$ docker build -t shimmie2-apache --build-arg upload_max_filesize=1G .
```

The `upload_max_filesize` arg sets the corresponding `php.ini` setting, which overrides the low default of `2M`.

Set up the Shimmie data directory:

```
$ mkdir -p /path/to/data && chmod 777 /path/to/data
```

Create and run the container:

```
$ docker run --name shimmie -p 8000:80 -v /path/to/data:/var/www/html/data --restart unless-stopped -d shimmie2-apache
```

Navigate to `http://localhost:8000` and follow the prompts to set up your Shimmie instance.

## Making the most of Apache

Apache is much faster and more powerful than the barebones PHP development server. These are a few examples of what you can do with it.

### Enable nice URLs

"Nice URLs" makes your URLs look like this:

```
http://<shimmie>/post/view/1
```

Rather than this (the default):

```
http://<shimmie>/index.php?q=post/view/1
```

The `.htaccess` file contains rules for rewriting URLs to the nicer format. All you have to do is enable "nice URLs" from the board config page.

### For self-hosters

The following suggestions may benefit those self-hosting a private instance of Shimmie.

#### Password protection

With any web server (Apache included), by default, any client within the same network as the server can connect to it and view the hosted website. To prevent unauthorized access, you can use Apache's built-in password protection feature.

Open a shell inside your Shimmie container using `docker exec -it shimmie bash`, then create an Apache password:

```
# htpasswd -c /etc/apache2/.htpasswd shimmie
```

Add this to `/etc/apache2/apache2.conf` to enable password protection:
```
<Directory "/var/www/html">
	AuthType Basic
	AuthName "Restricted Content"
	AuthUserFile /etc/apache2/.htpasswd
	Require valid-user
</Directory>
```

#### Secure transport

If you enable Apache's password protection, clients without the password can no longer directly access your server. However, in many cases, clients inside your network can still passively observe ("sniff") the traffic on your network, which means they could acquire the password if they are sniffing while you enter it.

##### HTTPS

To prevent sniffing and other man-in-the-middle attacks, almost all modern websites use HTTPS (HTTP + TLS). Unfortunately, enabling HTTPS on your selfhosted web server isn't as easy as clicking a button or running a terminal command. You have two options:

1. Purchase a domain name, register with a Certificate Authority, and tell Apache to use your globally-valid certificate.
	* This is doable, but vastly overkill for a selfhosted private web server, and costs money.

2. Locally generate your own Certificate Authority, issue a certificate to yourself, and configure all your devices (from which you want to access your server) to trust this certificate.
	* This is also doable, but unfortunately is usually quite complicated to set up, and web browsers don't always respect your trust preferences. (For example, Firefox uses it's own CA database rather than the OS-provided one.)

Neither are very great for a private, selfhosted web server.

##### SSH port forwarding

A much simpler (and possibly more secure) option is to use SSH port forwarding. SSH client software with port forwarding functionality is available for nearly every modern device, including Windows, macOS, Android ([Termux](https://termux.dev), [ConnectBot](https://github.com/connectbot/connectbot), and even [iOS](https://apps.apple.com/us/app/sshtunnel/id1260223542).

On the server side, all you have to do is enable SSH.

On the client side, you run this command:

```
$ ssh -L 9000:localhost:8000 -fNT user@host
```

This will configure SSH to forward port 8000 on the server to port 9000 on the client.

If you are on a device without an SSH command-line utility installed and are instead using a graphical SSH client, just look for the "port forwarding" option.

To access your website, visit `http://localhost:9000`. The request will be tunneled through the secure SSH connection.
