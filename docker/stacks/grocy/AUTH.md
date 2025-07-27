Setup procedure originally followed from https://www.reddit.com/r/grocy/comments/18avtb7/comment/mqynoyx/ and preserved below.

---

Don't be like me and go through all of the work to deploy an LDAP outpost with all of the trimmings just to find out that you can enable `ReverseProxyAuthMiddleware` in Grocy config.php

    Setting('AUTH_CLASS', 'Grocy\Middleware\ReverseProxyAuthMiddleware');`  
    `Setting('REVERSE_PROXY_AUTH_HEADER', 'X-Authentik-Username'); // The name of the HTTP header which your reverse proxy uses to pass the username (on successful authentication)`  
    `Setting('REVERSE_PROXY_AUTH_USE_ENV', false); // Set to true if the username is passed as environment variable

I have a domain-wide forward auth using Traefik, setup using [this article](https://medium.com/@learningsomethingnew/part-3-2-going-off-grid-authentication-authentik-with-traefik-to-protect-other-services-3471bf4b50c3) and added the following label to my docker-compose for traefik to force Authentik login if I'm not already:

`traefik.http.routers.grocy.middlewares=authentik-auth@file` from [this section](https://docs.goauthentik.io/docs/add-secure-apps/providers/proxy/server_traefik) of the guide