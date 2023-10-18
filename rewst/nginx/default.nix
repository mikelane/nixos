{
  services.nginx = {
    # I have found that sometimes a modification to the nginx settings here will not cause
    # nginx to reconfigure itself. If that happens, you can set enable to be false, run
    # the rebuild command. The result of `systemctl status nginx` should inform you that
    # There is no nginx service. Then come back here and set enable to true and rebuild.
    # This shoule start the service and update the nginx.conf.
    enable = true;
    enableReload = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;

    virtualHosts = {
      "*.local.rewst.io" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
        ];

        locations = {
          "/" = {
            return = "301 https://$host$request_uri";
          };
        };
      };

      "app.local.rewst.io" = {
        sslTrustedCertificate = /etc/ssl/certs/ca-bundle.crt;
        sslCertificate = ./certs/local.rewst.io.crt;
        sslCertificateKey = ./certs/local.rewst.io.key;
        addSSL = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
        ];

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3001/";
            recommendedProxySettings = true;
            extraConfig = "proxy_ssl_server_name on;";
          };

          "/_next/webpack-hmr" = {
            proxyPass = "http://127.0.0.1:3001/_next/webpack-hmr";
            proxyWebsockets = true;
            extraConfig = "proxy_ssl_server_name on;";
          };
        };
      };

      "api.local.rewst.io" = {
        sslTrustedCertificate = /etc/ssl/certs/ca-bundle.crt;
        sslCertificate = ./certs/local.rewst.io.crt;
        sslCertificateKey = ./certs/local.rewst.io.key;
        addSSL = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
        ];

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:4000/";
            recommendedProxySettings = true;
            extraConfig = "proxy_ssl_server_name on;";
          };

          "/subscriptions" = {
            proxyPass = "http://127.0.0.1:4000/subscriptions";
            proxyWebsockets = true;
            extraConfig = "proxy_ssl_server_name on;";
          };
        };
      };

      "engine.local.rewst.io" = {
        sslTrustedCertificate = /etc/ssl/certs/ca-bundle.crt;
        sslCertificate = ./certs/local.rewst.io.crt;
        sslCertificateKey = ./certs/local.rewst.io.key;
        addSSL = true;
        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
        ];

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:6066/";
            recommendedProxySettings = true;
            # extraConfig = "proxy_ssl_server_name on;";
          };
        };
      };
    };
  };

}
