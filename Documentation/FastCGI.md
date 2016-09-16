# Kitura FastCGI

The Kitura framework includes a [FastCGI 1.0](http://www.mit.edu/~yandros/doc/specs/fcgi-spec.html) compliant server that has been tested with the FastCGI connector modules included in the following web server packages:

- [Nginx](http://www.nginx.org) with the standard [FastCGI proxy module](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- [Apache 2.4](https://httpd.apache.org) with [mod_proxy_fcgi](https://httpd.apache.org/docs/trunk/mod/mod_proxy_fcgi.html)

The FastCGI server allows you to easily integrate your Kitura application into a standard web server environment, leveraging the existing features provided by a purpose-built web server. This lets you easily add functionality such as advanced protocol support (HTTPS, HTTP/2.0), HTTP keep-alive, high performance static file delivery, or URL redirect/rewrite services without having to incur the overhead or complexity of building anything into your application code.

In addition, the FastCGI server passes all HTTP headers received by your web server directly to your application, presenting them to your code as if the client had directly connected to Kitura. This has the potential to negate the need to analyze additional HTTP headers such as ```X-Forwarded-For```, simplying the application development process.

## FastCGI Compliance

At this time, Kitura implements a FastCGI 1.0 compliant server without keep alive or connection multiplexing support. These features are planned in a future release of Kitura.

## Enabling FastCGI Support In Your Kitura Application

This is a basic Kitura application, complete with a router, a "Hello World" route, and FastCGI server:

```swift
let router = Router()

router.get("/") {
    request, response, next in 
    
    response.send("Hello world!")
    next()
}

Kitura.addFastCGIServer(onPort: 9000, with: router)

Kitura.run()
```

No additional changes are needed to support FastCGI. Kitura provides it's FastCGI services in a manner that is completely transparent to your application code.

FastCGI servers and HTTP servers can even co-exist in the same application, simplifying your development and production deployment process:

```swift
let router = Router()

router.get("/") {
    request, response, next in 
    
    response.send("Hello world!")
    next()
}

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.addFastCGIServer(onPort: 9000, with: router)

Kitura.run()
```

## Configuring Your Web Server

Once your Kitura application is running with FastCGI enabled, you must configure your web server to forward requests to your FastCGI port.

### Nginx

By default, Nginx on Ubuntu (as installed by ```apt-get install nginx```) ships with the FastCGI proxy module pre-enabled and ready to use. No additional software installation is necessary. This is also the case with Nginx on OS X when installed using either [Homebrew](http://brew.sh) or [MacPorts](https://www.macports.org).

To configure Nginx to forward requests to Kitura over FastCGI, simply modify your Nginx configuration to use the ```fastcgi_pass``` configuration directive within a ```location``` block. 

On Ubuntu distributions, this is typically done in a site-specific file located such as ```/etc/nginx/sites-enabled/default```.

##### Forward all requests from Nginx to Kitura:

```
location / {
	fastcgi_pass <hostname or IP address of Kitura>:9000;
	include fastcgi_params;
}
```

You can also mix a variety of ```fastcgi_pass``` parameters contained within any number of unique  ```location``` blocks in order to customize the web routing of your Nginx configuration as necesssary to your application.

A common practice is to use a ```location``` block to serve any static files directly from Nginx, forwarding any other requests to Kitura for dynamic processing.

##### Handle static files natively, forwarding everything else to Kitura:

```
# Static Folder for CSS, JS, PNG Files
location /static {
	alias /var/www/my-kitura-app/static;
	try_files $uri $uri/ =404;
}
# All other requests forwarded to Kitura
location / {
	fastcgi_pass 127.0.0.1:9000;
	include fastcgi_params;
}
```

**Note:** Please ensure that ```include fastcgi_params;``` is included along with your ```fastcgi_pass``` directive (as in the above examples). This ensures that Nginx transmits additional, mandatory header information to Kitura.

### Apache 2.4

Apache 2.4 on Ubuntu installations (as installed by ```apt-get install apache2```) ships with the ```mod_proxy_fcgi``` module pre-installed, but disabled by default (along with the related ```mod_proxy``` module).

To configure Apache 2.4 to forward requests to Kitura over FastCGI, begin by enabling the necessary modules:

```
$ sudo a2enmod proxy_fcgi
Considering dependency proxy for proxy_fcgi:
Enabling module proxy.
Enabling module proxy_fcgi.
To activate the new configuration, you need to run:
  service apache2 restart
```

Next, modify your Apache configuration file to use the ```ProxyPass``` configuration directive. On Ubuntu distributions, this is typically done in a site-specific file located such as ```/etc/apache2/sites-enabled/000-default.conf```.

##### Forward all requests from Apache to Kitura:

```
<VirtualHost *:80>
  ServerName www.example.com
  ServerAdmin me@example.com
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
  ProxyPass / "fcgi://<hostname or IP address of Kitura>:9000/"
</VirtualHost>
```

As in the Nginx examples shown earlier in this document, you may want to configure Apache to serve static files from a specific directory, while forwarding all other requests to Kitura for dynamic processing.

##### Handle static files natively, forwarding everything else to Kitura:

```
<VirtualHost *:80>
  ServerName www.example.com
  ServerAdmin me@example.com
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
  DocumentRoot /var/www/my-kitura-app
  ProxyPass /static !
  ProxyPass / "fcgi://127.0.0.1:9000/"
</VirtualHost>
```
