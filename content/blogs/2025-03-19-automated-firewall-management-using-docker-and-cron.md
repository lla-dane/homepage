---
date: 2025-03-19T00:00:00Z
title: Automated Firewall management usign Docker and Cron
---

> Simulating automated firewall co**nfiguration using Docker, cron jobs, and UFW to ensure consistent security policies across multiple server roles**

# Introduction

Managing firewall rules across multiple servers can be tedious, especially in dynamic environments where configurations change frequently. In this blog we will explore how to **automate firewall management** using **Docker, cron jobs and UFW (Uncomplicated Firewall).** We’ll simulate a real-world scenario where different server roles require unique server rules and ensure they are consistently enforced using a centralized repository.

By the end of this guide, you’ll have a working setup where firewall rules are automatically applied and updated periodically across your Dockerized environment.

# Why Automate Firewall Management?

Manually managing firewall rules across multiple servers can lead to:

*   Inconsistent configurations - Some servers may have outdated or missing rules.
    
*   Security risks - Open ports may be accidentally left unprotected.
    
*   Operational overhead - Manually updating firewall rules is time-consuming.
    

> Complete code: [https://github.com/lla-dane/Rust/tree/master/firewall-configs](https://github.com/lla-dane/Rust/tree/master/firewall-configs)

# Setup

## Simulation overview

*   We will simulate 3 server roles - Web server, database server and bastion host.
    
*   Automated firewall rule enforcement - Using cron jobs to pull the latest firewall configs from a central repository.
    
*   A secure LAN env - Using Docker networking to isolate and simulate server interactions.
    

## Setting up firewall rules

We will make a ***firewall-configs*** repo like this:

### Server Roles

1.  ***webserver.rules*** : A webserver is basically a machine that hosts websites, serving web pages and other resources to users over the internet. So by default only 3 kinds of communications need to happen with a webserver.
    

*   SSH (port 22) - Administrator access for debugging and deployment updates.
    
*   HTTP (port 80) - Serving regular web traffic
    
*   HTTPS (port 443) - Secure, encrypted communication with users.
    

```bash
#!/bin/bash
set -x 

yes | ufw reset # resets all firewall rules to ensure clean slate
ufw default deny incoming # Deny all incoming requests
ufw default allow outgoing # Allow all outgoing requests
ufw allow 22/tcp   # ssh
ufw allow 80/tcp   # http
ufw allow 443/tcp  # https

yes | ufw enable   # enables the firewall with configured rules
```

2.  ***databaseserver.rules*** : A database server is responsible for storing, managing, and serving data to applications and other services. It typically does not interact directly with end-users but communicates with web servers or application servers to process queries and return results.
    
    By default, only two types of communication are necessary for a database server:
    
    *   SSH (port 22) - Administrator access for debugging and deployment updates.
        
    *   MySQL (port 3306) – Enables database connections from trusted application servers or web servers that need to read/write data.
        

```bash
#!/bin/bash
set -x

yes | ufw reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp   # Allow SSH
ufw allow 3306/tcp # Allow MySQL

yes | ufw enable
```

2.  ***bastion.rules :*** A bastion host acts a secure entry point into a private network, allowing administrators to access internal server securely. It is designed to be the only publicly accessible server, reducing the attack surface and adding an extra layer of security.
    
    By default, only one type of communication is necessary for a bastion host:
    

*   **SSH (port 22)** – Allows administrators to securely connect to the bastion host and then access other internal servers from there.
    

```bash
#!/bin/bash
set -x

yes | ufw reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp   # Allow SSH

yes | ufw enable
```

### Firewall imposing script

This script automates firewall rule updates based on the server’s role. It pulls the latest configurations from Github, identifies the server’s role, and applies the corresponding firewall rules. Logs are maintained for tracking, ensuring consistent and up-to-date security policies.

```bash
#!/bin/bash
#This script applies the respective firewall config as the server-name

LOG_FILE="/var/log/firewall-update.log"
GIT_PATH="/usr/bin/git"
UFW_PATH="/usr/sbin/ufw"
FIREWALL_CONFIG_DIR="/firewall-configs/roles"

echo "🚀 Updating firewall rules - $(date)" | tee -a $LOG_FILE

# Step 1: Pull the latest firewall rules from GitHub
cd /firewall-configs || exit 1
$GIT_PATH pull origin master >> $LOG_FILE 2>&1

# Step 2: Detect server role
if [ ! -f /etc/server-role ]; then
    echo "❌ Server role file not found! Exiting." | tee -a $LOG_FILE
    exit 1
fi

ROLE=$(cat /etc/server-role)
echo "🔍 Server role detected: $ROLE" | tee -a $LOG_FILE

# Step 3: Apply the correct firewall rules
RULE_FILE="$FIREWALL_CONFIG_DIR/$ROLE.rules"

if [ -f "$RULE_FILE" ]; then
    echo "⚙️ Applying firewall rules from $RULE_FILE" | tee -a $LOG_FILE
    bash "$RULE_FILE" >> $LOG_FILE 2>&1
    echo "✅ Firewall rules applied successfully!" | tee -a $LOG_FILE
else
    echo "❌ No firewall rules found for role '$ROLE'. Skipping." | tee -a $LOG_FILE
    exit 1
fi
```

This script will be executed inside the docker containers, everytime the cron job will be trigered to update firewall configurations.

## Setting up the network and containers

1.  First we create Docker network to simulate a private LAN environment for our servers
    

```bash
docker network create --subnet=192.168.1.0/24 firewall-net
# 192.168.1.0/24 means there are 255 available IP points in this network.
# From 192.168.1.0.0 to 192.168.1.0.254
```

We create three containers, each representing a different server role:

```bash
docker run -dit --name webserver --net firewall-net --privileged --ip 192.168.1.10 ubuntu bash
docker run -dit --name databaseserver --net firewall-net --privileged --ip 192.168.1.20 ubuntu bash
docker run -dit --name bastion --net firewall-net --privileged --ip 192.168.1.30 ubuntu bash
```

> ⚠️ **Security Warning:** The `--privileged` flag gives root privileges inside the container. In a real-world setup, use least privilege principles.

## Installing required packages inside the containers

Enter each container and install UFW, cron, Git and nano

```bash
docker exec -it webserver bash
apt update && apt install ufw git cron nano -y
```

Repeat this for databaseserver and bastion

Cloning the central Firewall Configuration Repository

```bash
git clone https://github.com/<USERNAME>/firewall-configs.git
echo "webserver" > /etc/server-role  # Change accordingly for each server role
```

## Automating Firewall Updates with Cron

We use a cron job, to execute a command periodically in any kind of system. Here we use the firewall rules imposing script to execute periodically (say every 1 min) using a cron job the containers.

```bash
export EDITOR=nano
crontab -e 

# Add the follwing line to fetch and apply the latest firewall rules every minute
*/1 * * * * /bin/bash /firewall-configs/scripts/apply_firewall.sh >> /var/log/firewall-update.log 2>&1

service cron start
```

## Testing the Firewall Rules

*   To verify if our automated firewall rules are working, check UFW status or logs;
    

```bash
ufw status verbose # Firewall config
# Output for web server:
# Status: active
# Logging: on (low)
# Default: deny (incoming), allow (outgoing), deny (routed)
# New profiles: skip

# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW IN    Anywhere
# 80/tcp                     ALLOW IN    Anywhere
# 443/tcp                    ALLOW IN    Anywhere
# 22/tcp (v6)                ALLOW IN    Anywhere (v6)             
# 80/tcp (v6)                ALLOW IN    Anywhere (v6)             
# 443/tcp (v6)               ALLOW IN    Anywhere (v6) 


cat /var/log/firewall-update.log # Logs during the script execution
```

*   Try making network connections that should be blocked:
    

```bash
docker exec -it webserver ssh 192.168.1.20   # Should fail
docker exec -it databaseserver curl -v 192.168.1.10:80  # Should fail
docker exec -it webserver nc -zv 192.168.1.20 3306  # Should fail
```

Explicitly allow access to internal IP addresses

```bash
docker exec -it databaseserver ufw allow from 192.168.1.10 to any port 22
docker exec -it databaseserver ufw reload

# Now SSH from webserver -> databaseserver should work
```

# Conclusion

Automating firewall management ensures consistency, reduces human error, and enhances security. In this simulation, we used Docker, cron jobs, and UFW to implement a self-updating system that adapts dynamically based on predefined role-based configurations.

This concept can be extended further by:  
🔹 Integrating with **CI/CD pipelines** to push firewall updates automatically.  
🔹 Using **Ansible or Terraform** for managing firewall configurations at scale.  
🔹 Implementing **audit logging and monitoring** to track firewall rule changes.

What are your thoughts on this approach? Let me know in the comments! 🚀