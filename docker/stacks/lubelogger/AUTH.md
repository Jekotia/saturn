Setup procedure originally followed from https://docs.lubelogger.com/Advanced/OpenID and preserved below.

---

# Authenticating via OpenID Connect

Configure OpenID Connect(OIDC) for LubeLogger via the following environment variables

```
OpenIDConfig__Name=Name of the OpenID Connect Provider
OpenIDConfig__ClientId=Client Id to Authenticate with the Provider
OpenIDConfig__ClientSecret=Client Secret to Authenticate with the Provider
OpenIDConfig__AuthURL=Authorization URL to the Provider's Login Page
OpenIDConfig__TokenURL=URL to retrieve user JWT from the Provider
OpenIDConfig__RedirectURL=https://<yourlubeloggerdomain.com>/Login/RemoteAuth(must be HTTPS)
OpenIDConfig__Scope=Scope to request from Provider(default: openid email)
OpenIDConfig__ValidateState=true/false(default: false) - whether LubeLogger should validate state.
OpenIDConfig__UsePKCE=true/false(default: false) - whether LubeLogger should use PKCE
OpenIDConfig__DisableRegularLogin=true/false(default: false) - auto re-direct user to OIDC login.
OpenIDConfig__UserInfoURL=UserInfo URL as alternative option to retrieve user claims(required for certain OpenID Providers)
OpenIDConfig__LogOutURL=Log Out URL for OIDC Provider, required if DisableRegularLogin=true.
```

If you're using the Windows Standalone executable, add the following section into `appsettings.json`

```
  "OpenIDConfig": {
    "Name": "",
    "ClientId": "",
    "ClientSecret": "",
    "AuthURL": "",
    "TokenURL": "",
    "RedirectURL": "",
    "Scope": "openid email",
    "ValidateState": true/false,
    "UsePKCE": true/false,
    "DisableRegularLogin": true/false,
    "UserInfoURL": "",
    "LogOutURL": ""
  }
 ```

The following sample shows how to set up OIDC with Google as the provider with the LubeLogger instance running on `https://localhost:5011`

```
OpenIDConfig__Name=Google
OpenIDConfig__ClientId=xxx.apps.googleusercontent.com
OpenIDConfig__ClientSecret=<your Google API Client Secret>
OpenIDConfig__AuthURL=https://accounts.google.com/o/oauth2/auth
OpenIDConfig__TokenURL=https://oauth2.googleapis.com/token
OpenIDConfig__RedirectURL=https://localhost:5011/Login/RemoteAuth
OpenIDConfig__Scope=email
OpenIDConfig__ValidateState=true
OpenIDConfig__UsePKCE=false
OpenIDConfig__UserInfoURL=https://openidconnect.googleapis.com/v1/userinfo
OpenIDConfig__DisableRegularLogin=false
```

## State Validation
The ValidateState environment variable determines if LubeLogger should validate the state token echoed back by the OIDC provider. This is set to false by default, if enabled, LubeLogger will fail any login attempts where the state token is not identical to what it sent to the provider. Leave this disabled if you wish to have IdP-initiated SSO.

## Proof of KeyCode Exchange(PKCE)
The UsePKCE environment variable determines if LubeLogger should generate and pass in a SHA-256-hashed challenge code to the OIDC provider.

## Testing
Once you have all these environment variables injected correctly, you should see the ability to login via your OIDC provider. Note: Currently LubeLogger only supports one OIDC provider.

![](/Advanced/OpenID/a/image-1726781322923.png)

![](/Advanced/OpenID/a/image-1726781326911.png)

LubeLogger uses the user's email address to authenticate against a registered user, the email address provided by the OIDC provider must match the email address of the user in the system.

If the user is attempting to login via OIDC but does not have an account with LubeLogger, they will be prompted for a registration token and to set up a username which will then allow them to log in. Note that the registration token is only required for their first time logging in.

### Advanced Troubleshooting

The Remote Auth Debug endpoint allows users to diagnose OIDC-related issues by stepping through it:

1. Set `OpenIDConfig__RedirectURL` to `https://yourlubeloggerdomain/Login/RemoteAuthDebug`
2. Configure your OpenID Provider so that `https://yourlubeloggerdomain/Login/RemoteAuthDebug` is a valid Redirect URL
3. Login using OIDC, instead of being redirected to login, you will be redirected to a page that displays checks and results.

Example scenarios(details redacted):

All checks passed and a user is identified:

![](/Advanced/OpenID/a/image-1743433228696.png)

All checks passed but no user is identified with the email(will be redirected to register under normal circumstances)

![](/Advanced/OpenID/a/image-1743433340241.png)

Failed State Validation, Expired OpenID Code and/or OpenID not returning `id_token`:

![](/Advanced/OpenID/a/image-1743433430561.png)

Failed Claim Validation(no email returned from OpenID Provider):

![](/Advanced/OpenID/a/image-1743433568647.png)

#### Authelia >= v4.39

There are [breaking changes](https://www.authelia.com/integration/openid-connect/openid-connect-1.0-claims/#restore-functionality-prior-to-claims-parameter) for users using Authelia with version >= 4.39

This is because LubeLogger utilizes the legacy method of retrieving the email claim via the id_token, which Authelia has deprecated as of v4.39.

If you're using LubeLogger <= v1.4.6, use the workaround below, otherwise, you can inject your Authelia's userinfo endpoint into the UserInfoURL environment variable, note that `userinfo_signed_response_alg` must be `none` in order for LubeLogger to integrate properly with Authelia

Authelia config in identity_providers:

```
identity_providers:
   oidc:
     claims_policies:
       legacy_claims:
         id_token: ['email', 'email_verified', 'preferred_username', 'name']
   ...
```

Authelia config for LubeLogger client:

```
    - client_id: lubelogger
      client_name: "Lube Logger"
      ...
      claims_policy: "legacy_claims"
```