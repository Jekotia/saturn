Setup procedure originally followed from https://www.reddit.com/r/navidrome/comments/r8834t/reverse_proxy_authentication_with_authentik/ and preserved below.

---

Reverse proxy authentication with Authentik

A while back I created an extensive guide on how to use [reverse proxy authentication](https://www.navidrome.org/docs/usage/security/#reverse-proxy-authentication) with Navidrome. When the feature was added to Navidrome I was still using nginx, vouch proxy and Gitea to do my Single Sign on. Since then things have evolved and [Authentik](https://goauthentik.io/) is my goto SSO solution.

In this guide I'm going to explain how to login to Navidrome with Authentik.

# Authentik

Authentik combines three parts that were separate in my last guide: Reverse Proxy, Authentication Provider and User Management tool. It's also just a single `docker compose up` away from running.

[Following](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script) [these](https://www.rockyourcode.com/how-to-install-docker-compose-v2-on-linux-2021/) [three](https://goauthentik.io/docs/installation/docker-compose) guides I did the following:

    #starting in home folder
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    
    #Install Docker Compose
    mkdir -p ~/.docker/cli-plugins
    curl -sSL https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    
    #Get Authentik
    mkdir /srv/Authentik
    curl -sSL https://goauthentik.io/docker-compose.yml -o /srv/Authentik/docker-compose.yml
    
    #Important: Now follow the steps in the Authentik guide to generate passwords/secrets
    #Run Authentik
    docker compose up

Authentik should now be reachable from  https://<your server>/if/flow/initial-setup/. Login using the generated password.

Create a user with the same username as the user that will use Navidrome.

# Navidrome

With Authentik running we're going to install Navidrome with Docker:

    #Create edit the file named /srv/Navidrome/docker-compose.yml like this:
    # This is just an example. Customize it to your needs.
    
    version: "3"
    services:
      navidrome:
        image: deluan/navidrome:latest
        restart: unless-stopped
        ports:
          - "4533:4533"
        environment:
          # Optional: put your config options customization here. Examples:
          ND_SCANSCHEDULE: 1h
          ND_LOGLEVEL: info
          ND_BASEURL: ""
          ND_REVERSEPROXYUSERHEADER: "X-authentik-username"
          ND_REVERSEPROXYWHITELIST: "0.0.0.0/0"
        volumes:
          - "./data:/data"
          - "/path/to/your/music/folder:/music:ro"

As you can see we have added some extra environment variables to enable reverse proxy authentication.

Now run `docker compose up -d` and create a new user in Navidrome.

# Back to Authentik

We are going to configure the embedded proxy "Outpost" and insert a domain name in the configuration:

![img](kd3z42m0ud381 "Embedded Proxy Outpost ")

Create a new "Proxy Provider" under Resources -> Providers:

![img](1q1y1ityvd381 "Creating the Proxy Provider")

Create a new "Application" and add the newly create navidromeProvider:

![img](693enzdawd381 "Application")

Lastly we need to add the Application to the embedded Proxy Outpost. So edit the "authentik Embedded Outpost" and add the newly created Navidrome application. The screenshot below will show more applications, yours will just show one: Navidrome.

![img](37ztpfmpwd381 "Adding Application to Outpost")

# Conclusion and discussion

After following and configuring it all you will be able to visit "[music.example.com](https://music.example.com)" and be greeted by an Authentik Login screen. After logging in with your Authentik credentials Authentik will forward you to Navidrome with your username without needing a second login screen.

I'm personally running Authentik on port 80 and port 433 so all traffic to my domain goes through Authentik first. You might want to run a reverse proxy like Caddy in front of that to split traffic to other applications.

As you might have noticed, I'm running Docker Compose V2. So no dash between Docker and Compose. The [0.0.0.0/0](https://0.0.0.0/0) in the Navidrome docker-compose.yml file is also a bit open, you might want to change that to your local ip range or even localhost if running on the same box. (example: [192.168.0.0/24](https://192.168.0.0/24))

If your Authentik username doesn't maches the Navidrome username, then you could add a special header to each username in Authentik. Of if you want your little brother to use your music libary. [https://goauthentik.io/docs/user-group/user#additionalheaders](https://goauthentik.io/docs/user-group/user#additionalheaders)