This is my personal configuration, fully deployed across multiple nodes in my server rack at home. I have, and will continue to, take every reasonable measure I can to generalise this so that others can easily adapt it to deploy services on their own server(s).

It's important to note that traefik (the reverse proxy & ingress point for all https traffic to services) should ***not*** be exposed to the internet, as this configuration has not been secured for such a deployment. Traefik is perfectly capable of being securely exposed to the internet, I simply have no need to do so.

---

# Requirements to use this setup without heavy modification
- A publically registered domain with control over DNS records via an API
    - Required by Traefik for LetsEncrypt HTTPS certificates

# Requirements to use this setup without minor modification
- Multiple nodes

---

# Nodes
- Hyperion
    - Roles
        - master node
        - compute (services)
        - overall management
    - Constraints
        - Storage; mounts are delegated to Enceladus where sensible
- Enceladus
    - Roles
        - secondary node
        - compute (services)
        - TrueNAS
    - Constraints
        - Keep light on services to avoid impacting NAS performance
- Mimas
    - Roles
        - secondary node
        - compute (services)
    - Constraints
        - CPU (2 cores/4 threads)
        - RAM (8GB)
        - Storage; mounts are delegated to Enceladus where sensible

# Key components:
## bootstrap/
Key components, in the form of Docker Compose stacks, that must be deployed outside of Komodo.

### bootstrap/hyperion/
This stack consists of Traefik & Komodo (Core, MongoDB, Periphery). This is intended to be deployed using Docker Compose. The following must be configured for the master node prior to deployment:
- copy `bootstrap/hyperion/.env.example` to `bootstrap/hyperion/.env` and set the following values:
    - `TIMEZONE` to your appropriate timezone. Refer to https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List if unsure. Use the `TZ identifier` column.
    - `NETWORK_DOMAIN` to the top-level domain that you have control over. This will be used by Traefik for ACME DNS01 challenges, as well for its dashboard URL.
    - `KOMODO_DB_USERNAME` to the username you wish to use for Komodo's Mongo database.
    - `KOMODO_DB_PASSWORD` to the password you wish to use for Komodo's Mongo database.
    - `SECRETS_CLOUDFLARE_EMAIL` to the email address used by your Cloudflare account.
    - `SECRETS_CLOUDFLARE_API_KEY` to the API key generated for Traefik to use on this node. This API key must have permissions to edit DNS records on $NETWORK_DOMAIN.

- copy `bootstrap/hyperion/komodo.env.example` to `bootstrap/hyperion/komodo.env` and set the following values:
    - `TZ` to your appropriate timezone. Refer to https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List if unsure. Use the `TZ identifier` column.
    - `KOMODO_TITLE` to what you want the web UI's title to be in your browser tabs.
    - Optionally, you may change any other values in this file, but caution should be taken and you should understand what the values you're changing do.

- copy `bootstrap/hyperion/komodo.secrets.env.example` to `bootstrap/hyperion/komodo.secrets.env` and set the following values:
    - `KOMODO_DB_USERNAME` to the same value used above
    - `KOMODO_DB_PASSWORD` to the same value used above
    - `KOMODO_PASSKEY` to a secure, randomly generated string. This is what's used to secure communication between Komodo components across different nodes. You will need to re-use your chosen string in any Komodo Periphery deployments.
    - `KOMODO_WEBHOOK_SECRET` to a secure, randomly generated string. This is what's used to authenticate webhooks. 
    - `KOMODO_JWT_SECRET` to a secure, randomly generated string.

## bootstrap/enceladus/
This stack consists of Komodo Periphery and a network definition to be used by Traefik once deployed to this node via Komodo. The network is defined here so that the full name is `bootstrap_proxy_private`, which is consistent with Hyperion's `bootstrap_proxy_private` and thus aids in container portability.

This is intended to be deployed via TrueNAS SCALE's Custom App YAML feature. The repository **must** be cloned to `/mnt/storage/srv/enceladus/docker` or have paths updated in `compose.yaml` **and** `$REPOSITORY_ROOT/komodo/stacks/core-enceladus.toml`. The following must be configured for this secondary node prior to deployment:
- copy `bootstrap/enceladus/komodo.env.example` to `bootstrap/enceladus/komodo.env` and set the following values:
    - `TZ` to your appropriate timezone. Refer to https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List if unsure. Use the `TZ identifier` column.
    - `PERIPHERY_ROOT_DIRECTORY` to the location you wish Komodo Periphery to store its data on this node.

- copy `bootstrap/enceladus/komodo.secrets.env.example` to `bootstrap/enceladus/komodo.secrets.env` and set the following values:
    - `KOMODO_PASSKEY` to the same value used when configuring Hyperion

In order to deploy this node on TrueNAS, the contents of `compose.yaml` must be copy-pasted into the Custom App YAML UI. After doing so, the network `bootstrap_proxy_private` must be manually created from the shell as TrueNAS will prefix the network name with `ix-`, breaking this particular consistency across nodes that is utilised to simplify moving services. The command to do so is `docker network create -d bridge --scope local bootstrap_proxy_private`.

If deploying outside of TrueNAS, this stack can be deployed using Docker Compose, and no additional steps are necessary.

# Limitations
- As of writing, Komodo does not support "default-to-a-predetermined-value-if-undefined" behaviour for variables, unlike Docker Compose. This means that, in a Komodo stacks' Environment section, I will not be defining variables I do not use. Instead, they will be commented out so that it's clear what changes can be made purely from the environment file.