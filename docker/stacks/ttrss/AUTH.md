Setup procedure originally followed from https://gitlab.tt-rss.org/tt-rss/plugins/ttrss-auth-oidc and preserved below.

---

# OIDC authentication plugin

This is a system plugin, it has to be enabled globally through `TTRSS_PLUGINS`.

If everything is configured correctly, another login button will appear on the login form, which
you can use to log in through OpenID.

If `TTRSS_AUTH_OIDC_VALIDATE_INTERVAL` is enabled (> 0, disabled by default), OIDC access token is
stored and validated periodically, reauthentication is triggered if it becomes inactive.

Before enabling, make sure OIDC access token is set to a sufficiently long TTL (if using Authentik, it's in
your OAuth2 application provider -> Advanced Protocol settings -> Access Token validity), otherwise you'll get
constantly logged out.

## Examples

### Authentik

Setup provider & application in the Authentik admin UI as usual. Example uses `tt-rss` slug.

Plugin settings (`.env`):

```ini
TTRSS_AUTH_OIDC_NAME=Authentik
TTRSS_AUTH_OIDC_URL=https://auth.example.com/application/o/tt-rss/
TTRSS_AUTH_OIDC_CLIENT_ID=client-id
TTRSS_AUTH_OIDC_CLIENT_SECRET=client-secret

# in seconds, -1 disables
TTRSS_AUTH_OIDC_VALIDATE_INTERVAL=-1

# or sub, etc
TTRSS_AUTH_OIDC_CLIENT_USERNAME_CLAIM=preferred_username
```

### Authelia

```yml
identity_providers:
...
- id: test-ttrss
        secret: your-secret-token
        public: false
        scopes:
          - openid
          - email
          - profile
        redirect_uris:
          - "https://example.com/tt-rss"
        userinfo_signing_algorithm: none
```

Plugin settings (`.env`):

```ini
TTRSS_AUTH_OIDC_NAME=Authelia
TTRSS_AUTH_OIDC_URL=https://auth.example.com/
TTRSS_AUTH_OIDC_CLIENT_ID=test-ttrss
TTRSS_AUTH_OIDC_CLIENT_SECRET=your-secret-token
```

### Keycloak

When using Keycloak, set `TTRSS_AUTH_OIDC_URL` to base realm URL:

```properties
TTRSS_AUTH_OIDC_URL=https://keycloak.example.com/realms/YourRealm
```