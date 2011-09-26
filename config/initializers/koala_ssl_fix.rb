# This fix helps Faraday gem to find global certificates for SSL verification. Without it all requests to HTTPS URLs fail. The problem appears on Ubuntu.

Koala::HTTPService.http_options = {:ssl => {:ca_path => '/etc/ssl/certs'}}