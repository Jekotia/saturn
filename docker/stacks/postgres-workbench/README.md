Note that all volume mountpoints must be owned by 5050:5050, as this is the UID:GID that the processes within the container run as.

# Security Notice
This container has been configured to be less convenient at the cost of security, for development work and ad-hoc database access. It should not be deployed as-is to a production environment.