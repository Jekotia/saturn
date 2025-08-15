This document serves as a reference for what authentication, if any, is used for a given service.

| auth shorthand          | Description                                  |
| ----------------------- | -------------------------------------------- |
| N/A                     | No web service to protect                    |
| none                    | No authentication                            |
| self                    | The services' built-in authentication system |
| forwardAuth             | Traefik forwardAuth handled by Authentik     |
| X-Authentik-Username    | Traefik forwardAuth handled by Authentik, using `X-Authentik-Username` header to login to native account |
| OIDC                    | OpenID Connect handled by Authentik          |
| TODO                    | Skipped, will be handled later               |


# bootstrap
## enceladus
| service         | auth        |
| --------------- | ----------- |
| komodo agent    | N/A         |

## hyperion
| service   | auth        |
| --------- | ----------- |
| authentik | self        |
| komodo    | self        |
| traefik   | forwardAuth |

# stacks
| stack                     | auth |
| ------------------------- | ---- |
| 13ft                      | none |
| actualbudget              | OIDC |
| audiobookshelf            | OIDC |
| bazarr                    | forwardAuth |
| bitwarden                 | self |
| bytestash                 | self |
| code-server               | forwardAuth |
| convertx                  | forwardAuth |
| core-enceladus            | forwardAuth |
| diun                      | N/A |
| emulator-source-backups   | OIDC |
| foundry                   | TODO |
| github-pages              | none |
| grocy                     | X-Authentik-Username |
| homepage                  | none |
| immich                    | OIDC |
| it-tools                  | none |
| karakeep                  | OIDC |
| kavita                    | self |
| lidarr                    | forwardAuth |
| lyrionmusicserver         | none |
| mylar                     | forwardAuth |
| navidrome                 | X-Authentik-Username |
| nextcloud                 | OIDC |
| ntfy                      | TODO |
| obsidian-livesync         | self |
| omni-tools                | TODO |
| orb                       | N/A |
| overseerr                 | self |
| paperless                 | OIDC |
| plexms                    | self |
| plextraktsync             | N/A |
| portainer                 | OIDC |
| prowlarr                  | forwardAuth |
| qbittorrent               | self |
| radarr                    | forwardAuth |
| readarr                   | forwardAuth |
| requestrr                 | self |
| resilio-sync              | self |
| romm                      | OIDC |
| rustdesk                  | N/A |
| sonarr                    | forwardAuth |
| spotizerr                 | forwardAuth |
| status-overview           | none |
| stirlingpdf               | TODO |
| tdarr-server              | self |
| ttrss                     | OIDC |
| uptime-kuma               | forwardAuth |
| vscodium                  | forwardAuth |
| whatsupdocker             | OIDC |