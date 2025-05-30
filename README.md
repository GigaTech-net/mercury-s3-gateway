# Project Mercury S3 Gateway

## Local Testing

Create a `settings` file. See [settings.example](/settings.example) for formatting and example values.  
Do not commit the settings file to source control.  
To allow proper routing for SPAs, add the sub-folder for the application to the file [s3_server.conf.template](/common/etc/nginx/templates/gateway/s3_server.conf.template).

To run the gateway on [http://localhost:8080](http://localhost:8080):  
`docker build --file Dockerfile.oss -t pro/s3-gateway:latest .`  
`docker run --env-file ./settings -p 8080:80 pro/s3-gateway:latest`

---  

[![CI](https://github.com/GigaTech-net/mercury-s3-gateway/actions/workflows/main.yml/badge.svg)](https://github.com/GigaTech-net/mercury-s3-gateway/actions/workflows/main.yml)
[![Community Support](https://badgen.net/badge/support/gigatech/blue?icon=jira)](https://gigatech-net.atlassian.net/jira/software/c/projects/PRO/boards/3/backlog)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

## NGINX S3 Gateway

## Introduction

This project provides a working configuration of NGINX configured to act as
an authenticating and caching gateway for to AWS S3 or another S3 compatible
service. This allows you to proxy a private S3 bucket without requiring users
to authenticate to it. Within the proxy layer, additional functionality can be
configured such as:

* Listing the contents of a S3 bucket
* Providing an authentication gateway using an alternative authentication
   system to S3
* Caching frequently accessed S3 objects for lower latency delivery and
   protection against S3 outages
* For internal/micro services that can't authenticate against the S3 API
   (e.g. don't have libraries available) the gateway can provide a means
   to accessing S3 objects without authentication
* Compressing objects ([gzip](examples/gzip-compression), [brotli](examples/brotli-compression)) from gateway to end user
* Protecting S3 bucket from arbitrary public access and traversal
* Rate limiting S3 objects
* Protecting a S3 bucket with a [WAF](examples/modsecurity)
* Serving static assets from a S3 bucket alongside a dynamic application
   endpoints all in a single RESTful directory structure

All such functionality can be enabled within a standard NGINX configuration
because this project is nothing other than NGINX with additional configuration
that allows for proxying S3. It can be used as-is if the predefined
configuration is sufficient, or it can serve as a base example for a more
customized configuration.

If the predefined configuration does not meet your needs, it is best to borrow
from the patterns in this project and build your own configuration. For example,
if you want to enable SSL/TLS and compression in your NGINX S3 gateway
configuration, you will need to look at other documentation because this
project does not enable those features of NGINX.

## Usage

This project can be run as a stand-alone container or as a Systemd service.
Both modes use the same NGINX configuration and are functionally equal in terms
features. However, in the case of running as a Systemd service, other services
can be configured that additional functionality such as [certbot](https://certbot.eff.org/)
for [Let's Encrypt](https://letsencrypt.org/) support.

## Getting Started

Refer to the [Getting Started Guide](docs/getting_started.md) for how to build
and run the gateway.

## Directory Structure and File Descriptions

```bash
common/                          contains files used by both NGINX OSS and Plus configurations
  etc/nginx/include/
    awscredentials.js            common library to read and write credentials
    awssig2.js                   common library to build AWS signature 2
    awssig4.js                   common library to build AWS signature 4 and get a session token
    s3gateway.js                 common library to integrate the s3 storage from NGINX OSS and Plus
    utils.js                     common library to be reused by all of NJS codebases
deployments/                     contains files used for deployment technologies such as
                                 CloudFormation
docs/                            contains documentation about the project
examples/                        contains additional `Dockerfile` examples that extend the base 
                                 configuration
jsdoc                            JSDoc configuration files
oss/                             contains files used solely in NGINX OSS configurations
plus/                            contains files used solely in NGINX Plus configurations
test/                            contains automated tests for validating that the examples work
Dockerfile.oss                   Dockerfile that configures NGINX OSS to act as a S3 gateway
Dockerfile.plus                  Dockerfile that builds a NGINX Plus instance that is configured
                                 equivalently to NGINX OSS - instance is configured to act as a 
                                 S3 gateway with NGINX Plus additional features enabled
Dockerfile.buildkit.plus         Dockerfile with the same configuration as Dockerfile.plus, but
                                 with support for hiding secrets using Docker's Buildkit
Dockerfile.latest-njs            Dockerfile that inherits from the last build of the gateway and
                                 then builds and installs the latest version of njs from source
Dockerfile.unprivileged          Dockerfiles that inherits from the last build of the gateway and
                                 makes the necessary modifications to allow running the container
                                 as a non root, unprivileged user.
package.json                     Node.js package file used only for generating JSDoc
settings.example                 Docker env file example
standalone_ubuntu_oss_install.sh install script that will install the gateway as a Systemd service
test.sh                          test launcher
```

## Development

Refer to the [Development Guide](docs/development.md) for more information about extending or testing the gateway.

## License

All code include is licensed under the [Apache 2.0 license](LICENSE.txt).

## other
