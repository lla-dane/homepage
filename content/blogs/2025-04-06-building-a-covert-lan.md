---
date: 2025-04-06T00:00:00Z
title: Building a Covert LAN - A Dockerized VPN Gateway using WireGuard and Nginx
---

> Establishing a secure, private network by integrating Wireguard VPN with Docker container services to ensure exclusive access through encrypted connections.

# Introduction

In an increasing noisy internet, privacy isn’t just about encrypting your data - it’s also about controlling who gets to see and expose your services in the first place. Imagining running a set of internal services, say a dashboard, an internal wiki, or a media server. You don’t want these exposed to the internet, and even your local network feels too open. What if you could make them disappear entirely from everything except a private VPN?

That’s the concept of building a covert LAN - a hidden internal network where your containers only speak to authenticated Wireguard peers, nothing more. In this blog, I’ll walk you through how I built one using Docker, `Wireguard`, and a sprinkle of `iptables` magic. You’ll get a clear idea of how to isolate services so well that even your own host machine can’t sneak past the guards unless it’s on the VPN.

# Why we want a covert LAN ?

This project started with a simple goal: keep my Dockerized services off the grid. Not off the internet — off everyhting. I didn’t want my NGINX container responding to some random local network scans, or my services being visible just because I’m on the same subnet.

> A quick word about **subnets:** A subnet — short for subnetwork — is a logical partition of an IP network. Devices withing the same subnet can usually talk to each other directly, without needing to go through the router. For example, your laptop, your phone, and you desktop might all be on `192:168.1.x`. That makes them neighbors — and neighbors can see each other.

So if my Docker container is listening on the default bridge and my host is on the same subnet, they’re technically visible. Even worse, someone else plugged into the same LAN — say at a coworking space or on campus — might also be on the subnet. That’s visibility risk.

What I wanted was a digital equivalent of a soundproof, windowless room. The containers shouldn’t know or care about who’s on the same subnet — unless they’ve come in the right door: the Wireguard VPN.

# What we’re building ?

Now let’s talk about what the architecture will look like. We’ve got a Docker network that contains some sensitive services — a web server, maybe an admin panel (for now just a NGINX server) — and we wrap that network inside a Wireguard gateway. The catch is, the services inside are only accessible through VPN.

Anyone not coming in via Wireguard? Doesn’t matter if they’re on the same physical machine or the same LAN — they’re blocked at the door.

This approach lets up simulate something like a ‘zero trust’ internal network, even for Docker containers. It’s sneaky little LAN in the shadows — accessible only to those who carry the right cryptographic keys.

# How it works ?

At the heart of this setup is network isolating and filtering. Docker gives us isolated networks by default, but those can still be accessed by the host or LAN users unless explicitly locked down. So we add a WireGuard container that acts as the gatekeeper, and we use iptables to enforce strict rules:

*   Only traffic coming from WireGuard-assigned IPs (like `10.8.0.2`) can talk to the internal Docker bridge.
    
*   the host? Blocked unless it tunnels through WireGuard.
    
*   The LAN? Doesn’t even see the services.
    

With this combo of namespaces, bridges, and packet filtering, we build a digital moat — a hidden enclave accessible only via VPN.

# Setup

In this simulation, this whole thing runs on a linux machine (Arch in this blog) with Docker. We will be using **docker-compose** to orchestrate the WireGuard gateway and some test containers — like NGINX — sitting behind it.

I chose Wireguard (*<s>basically because I failed to set up OpenVPN on my arch linux in the first place, LOL</s>*) because its lighweight, fast and dead simple to set up inside Docker. And **iptables?** Well… its not exactly a joy to use — the syntax feels like you’re casting ancient spells — but when you do get it right, its wildly powerful. We will use to enforce strict egress (who containers are allowed to talk to) and ingress rules (who are allowed in) so that if someone tries to reach my services outside the VPN, they’re hitting a brick wall.

Now that we’ve talked about why we’re doing this, it’s time to start building the actual foundation of this covert network. Everything runs in Docker — it’s clean, isolated, and portable. Plus, we can tear it down and rebuild it with a single **compose up** if we needed.

The hear to this setup is WireGuard. We’ll set up two containers: one as the **WireGuard access server**, and another as a **WireGuard client** that lives inside the same Docker network. Together, these form the secure tunnel that connects trusted clients to our isolated services.

## Pre-requisites

### ✅ A linux Machine (Preferably Arch)

I’m running this on Arch Linux, because I like control, minimalism, and sometimes pain. But you can use any modern Linux distro that has iptables, Docker, and support for wireguard kernel module. Ubuntu, Debian, Fedora — they’ll work fine.

Just make sure you have root access, and you’re comfortable using the terminal. This is not a GUI walkthrough.

### ✅ Docker & Docker Compose

You’ll need Docker up and running, obviously. Docker Compose makes it easier to spin up multi-container environments, so we’ll be using that too. Nothing fancy — just the standard setup.

If `docker --version` and `docker compose version` give you valid output, you’re good.

### ✅ Basic Networking & iptables Knowledge

You don’t need to be a expert, but you should have some idea of how IP ranges, interfaces, and firewall rules work. We’ll be crafting rules with iptables to strictly control access to our Docker network — so if you've never written a firewall rule before, prepare to do some learning.

Don’t worry, I’ll explain the why behind each rule — but I won’t be doing a deep dive on how TCP/IP works.

### 🚫 macOS and Windows: No Native iptables

*   macOS uses the pf (Packet Filter) firewall system — totally different from iptables. You can’t run `iptables` there unless you're using a Linux VM or container.
    
*   Windows has its own firewall stack (Windows Filtering Platform), and again, no native `iptables`.
    

### ✅A Curious and Paranoid Mindset

This project is about control and isolation. We’re not just setting up a VPN — we’re creating a controlled LAN inside Docker that’s invisible to the outside world unless you're inside the tunnel. It’s a bit of a puzzle and a lot of fun, especially if you enjoy tinkering with network namespaces, containers, and low-level firewall rules.

If that sounds like your vibe — let’s get to it.

## WireGuard access server

This is the gateway — the door into our secret LAN. You can set up the access servers for general usecase, by following this [blog](https://pimylifeup.com/wireguard-docker/). But we will do some different configurations.

After setting up `docker` and `docker compose`, we will set up the WireGuard server container.

*   We will create a directory to store the compose.yaml file for running WireGuard using Docker. It is also the same location we will be storing all of the configuration files for Wireguard. You can create a directory at `/opt/stacks/wireguard`
    
    ```bash
    sudo mkdir -p /opt/stacks/wireguard
    cd /opt/stacks/wireguard
    ```
    
    For the rest of the walkthrough, we expect that you are within this folder.
    
*   **Generating a Password Hash for your WireGuard Docker Container:** Within the terminal, run the following command. While typing out this command, ensure that you replace `<PASSWORD>` with the password you intend on using to access the WG-Easy web interface.
    
    ```bash
    docker run --rm -it ghcr.io/wg-easy/wg-easy wgpw '<PASSWORD>'
    ```
    
*   After running the above command, you should end up with a line that looks somewhat like what is shown below. This is a bcrypt hash of your password. However, before this line can be used in the Docker Compose file, it requires some modifications.
    
    ```bash
    # Example PASSWOKD_HASH
    PASSWORD_HASH='$2b$12$coPqCsPtcFO.Ab99xylBNOW4.Iu7OOA2/ZIboHN6/oyxca3MWo7fW'
    # MODIFIED PASSWORD_HASH (just remove the ('), and add additional $ after each dollar sign)
    PASSWORD_HASH=$$2b$$12$$coPqCsPtcFO.Ab99xylBNOW4.Iu7OOA2/ZIboHN6/oyxca3MWo7fW
    ```
    
*   **Creating a custom Docker Bridge Network**:
    
    ```bash
      docker network create \
      --driver bridge \
      --subnet 172.25.0.0/16 \
      --gateway 172.25.0.1 \
      covert_lan
    ```
    
    This does three things:
    
    *   Creates a bridge network called `covert_lan`.
        
    *   Uses a fixed subnet `172.25.0.0/16` so you can reliably build rules around it.
        
    *   Assigns a known gateway IP `172.25.0.1` to use in iptables, routing, etc.
        
    
    Fetch the network info
    
    ```bash
    docker network inspect covert_lan
    
    # Output (Look for Subnet and Gateway)
    "IPAM": {
        "Config": [
            {
                "Subnet": "172.25.0.0/16",
                "Gateway": "172.25.0.1"
            }
        ]
    }
    ```
    
    *   Writing a Docker Compose File for WireGuard: We are finally at the point where we can write the Docker Compose file for our WireGuard VPN. A Compose file is like a set of instructions that Docker will use to manage and run your WireGuard VPN.
        
        ```bash
        sudo nano compose.yaml
        ```
        
        Within this file, we will type the following lines.
        
        *   `<PASSWORD_HASH>`: Replace this placeholder with the value that you got earlier in on this guide. The password that was generated for this hash is what you will use to log in to the WG-Easy web interface.
            
        *   `<IPADDRESS>`: Next, specify the IP address or domain name where your VPN can be accessed. Here it will be the IP address of the access server container `172.25.0.2`.
            
        
        ```bash
        services:
          wg-easy:
            container_name: wg-easy
            image: ghcr.io/wg-easy/wg-easy
        
            environment:
              - PASSWORD_HASH=$$2b$$12$$coPqCsPtcFO.Ab99xylBNOW4.Iu7OOA2/ZIboHN6/oyxca3MWo7fW
              - WG_HOST=172.25.0.2
        
            volumes:
              - ./config:/etc/wireguard
              - /lib/modules:/lib/modules
            ports:
              - "51820:51820/udp"
              - "51821:51821/tcp"
            restart: unless-stopped
            cap_add:
              - NET_ADMIN
              - SYS_MODULE
            sysctls:
              - net.ipv4.ip_forward=1
              - net.ipv4.conf.all.src_valid_mark=1
            networks:
              - covert_lan
        ```
        
*   **Setting up the Wireguard Docker Stack:** To get our VPN up and running, we need to use the command below.
    
    ```bash
    docker compose up -d
    ```
    
*   **Accessing our WireGuard Docker Container Web Interface:** Before we can start using our new VPN. we will need to create a new client. Most of time this could be a pain with other VPN services, but with the WireGuard container that we are using its dead simple.  
    To access the web interface and create the client, follow the steps from 14 in [this blog.](https://pimylifeup.com/wireguard-docker/)
    
    Access the we interface here: `http://localhost:51821`.
    

## WireGuard client

Once you’ve created your WireGuard client using the web interface (assuming you're using something like the `LinuxServer.io` WireGuard container), you’ll get a `.conf` file — probably something like `wire_vpn.conf`. This is the configuration that your WireGuard client will use to connect to the VPN server.

```bash
sudo nano Downloads/wire_vpn.conf

# Output
[Interface]
PrivateKey = OIeJsiERVJGffJYF77ro24xd0i6wB5Q2T+YpZgn36mc=
Address = 10.8.0.2/24 # For the 1st client that you create
DNS = 1.1.1.1

[Peer]
PublicKey = DjqUtarLkB26ZnGWNhxBHwuYnU39eJKSSsHWYYiSnjY=
PresharedKey = jmbIwT89seHklvi3sSsYgJuBjlqVWK+P+0IVXKdadxo=
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 0
Endpoint = 172.20.0.2:51820
```

This is a general-purpose config — its designed to route all traffic from your client through the VPN (that’s what `AllowedIPs = 0.0.0.0/0, ::/0` means). But in our case, we’re not trying to build a full tunnel VPN. We’re building a covert LAN. Our goal is much tighter: we want to allow the client to access only services inside our Docker bridge network — nothing more, nothing less.

> My college Wi-Fi blocks VPN traffic — no exceptions. So instead of routing everything through the VPN, I set it up to only tunnel traffic destined for a private Docker network.
> 
> That means no packets ever leave my machine through the VPN unless they’re going to that isolated LAN. To the college network, its like the VPN doesn’t exist.
> 
> I still get full internet access for everything else, while quietly running a secure, private experiment lab in the background. Stealthy and effective.

So we’ll be making a few critical changes.

```bash
# 🚧 Modified Config: Making It Fit Our Setup
[Interface]
PrivateKey = SBXUhS5PNmWbGeI5EkYXpZCN+kcc9IBGRcFB90hJL1A=
Address = 10.8.0.2/24
DNS = 1.1.1.1
Table = off

[Peer]
PublicKey = DjqUtarLkB26ZnGWNhxBHwuYnU39eJKSSsHWYYiSnjY=
PresharedKey = vtAB/CT6yrTd1oFUl/NBOlZ/xgr76T1Q9OX0/qsCK3s=
AllowedIPs = 172.25.0.0/16
PersistentKeepalive = 25
Endpoint = 172.20.0.2:51820
```

Lets break down that down a bit.

*   `Table = off`: This tells WireGuard not to mess with your system routing table. Normally, when you connect to a VPN, WireGuard will inject routes for `AllowedIPs` . But we don’t want that. We’re already going to control what traffic goes through the VPN using our own routing or firewall logic. Setting `Table = off` gives us full control`.`
    
*   `AllowedIPs = 172.25.0.0/16`: This is the Docker bridge subnet. It tells the client: “only send traffic to this subnet through the VPN tunnel.“ That means only traffic bound for services on the Docker network will ever touch the WireGuard interface — which is exactly what we want.
    
*   `PersistentKeepalive = 25`: This just keeps the tunnel alive if the client is behind NAT or idle. You can tweak it or leave it out, but it helps with connection stability.
    

With this modified config, your WireGuard client becomes a stealthy visitor on your isolated Docker network. It doesn't route general internet traffic. It doesn't announce itself. It only has eyes for services behind the VPN — exactly how you’d want it for a private, zero-trust-style setup.

Now lets set up the required tools for setting up the VPN client. We’ll be using the `wg-quick` utility, which comes bundled with the `wireguard-tools` package. This little tool reads our `wire_vpn.conf` file and brings up the VPN interface with a single command. No need to mess around with a million options.

```bash
sudo pacman -S wireguard-tools
which wg-quick
wg --version
```

Now we need to move the wire\_vpn.conf file to this directory: `/etc/wireguard/` using this command

```bash
sudo cp Downloads/wire_vpn.conf /etc/wireguard/
```

Now just spin up the VPN tunnel with this command

```bash
sudo wg-quick up wire_vpn     # Connected

# Output (Something like this)

[#] ip link add wvpn type wireguard
[#] wg setconf wvpn /dev/fd/63
[#] ip -4 address add 10.8.0.2/24 dev wvpn
[#] ip link set mtu 1420 up dev wvpn
[#] resolvconf -a wvpn -m 0 -x

sudo wg-quick down wire_vpn   # Disconnected

# Output (Something like this)

[#] ip link delete dev wvpn
[#] resolvconf -d wvpn -f
```

## Spinning Up the `iptables` Rules 🧙‍♂️

Now that our WireGuard tunnel is alive and breathing, it’s time to lay down some strict laws—iptables style.

Think of this part as warding off uninvited guests. By default, Docker is a bit too friendly. It allows containers to be accessed from anywhere on the host, which is not what we want. Our mission is to build a covert LAN, right? That means **no outside access unless it comes through the VPN**.

Here’s where iptables comes in. It might not have the prettiest syntax (okay, it’s borderline arcane), but it’s incredibly powerful when it comes to controlling traffic flow at the network layer.

We use it to write rules like:

*   `Ingress filtering`: Only allow packets into our Docker network if they’re coming from the WireGuard interface. Anything else gets dropped at the gate—no questions asked.
    
*   `Egress control`: Prevent any app or user on the host from directly talking to Docker containers. That means no `curl`ing a container from the host, no sneak peeks. All traffic must route through the VPN tunnel.
    

This setup ensures one critical thing: even though the services are running on your machine, you can’t access them unless you're on the VPN. It's like running a secret server that even you can’t see without the right keys.

Lets set up the rules:

```bash
sudo iptables -I OUTPUT -d 172.20.0.0/16 ! -s 10.8.0.0/24 -j REJECT
```

### 💡 What this does:

*   `-I OUTPUT`: Inserts a rule at the **top** of the OUTPUT chain (so it’s processed first).
    
*   `-d 172.25.0.0/16`: Targets all packets going to Docker’s bridge network (`covert_lan` in your case).
    
*   `! -s 10.8.0.0/24`: Blocks anything **not** coming from the VPN subnet.
    
*   `-j REJECT`: Rejects the connection attempt (with an ICMP unreachable by default).
    

You can confirm it’s in place with:

```bash
sudo iptables -L OUTPUT -v --line-numbers
```

💾 Optional – Save it so it survives reboot:

```bash
sudo iptables-save | sudo tee /etc/iptables/iptables.rules
sudo systemctl enable iptables
sudo systemctl start iptables
```

Now lets check if our routing table is updated after setting up the rules:

```bash
route -n 

Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.16.68.1     0.0.0.0         UG    100    0        0 enp55s0f4u1
10.8.0.0        0.0.0.0         255.255.255.0   U     0      0        0 wire_vpn
172.16.68.0     0.0.0.0         255.255.252.0   U     100    0        0 enp55s0f4u1
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.18.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker_gwbridge
192.168.122.0   0.0.0.0         255.255.255.0   U     0      0        0 virbr0
```

If you see this line:

```bash
10.8.0.0        0.0.0.0         255.255.255.0   U     0      0        0 wire_vpn
```

Then that mean all the traffic from `10.8.0.0/24` will be routed form the `wire_vpn` tunnel, which we want because only that traffic will be accepted by our docker services.

## Set up the NGINX container:

We now want to launch a NGINX container and attach it to the `covert_lan` network:

```bash
docker run -d --name wire_ngicx --network covert_lan nginx
```

Inspect the `covert_lan` network to see if `wire_nginx` container is attached to it:

```bash
docker network inspect covert_lan 

# See for the containers: 
"Containers": {
            "18974b2b2d8ce2ae4959bc597d5008157bdc27a995b1d8b32f51fcfc9529626d": {
                "Name": "wg-easy",
                "EndpointID": "b471d2ca8aa4b01418dda16b0b874e4b18eb5813376e6aa66a411f05ec5570b5",
                "MacAddress": "0e:d5:34:12:d5:16",
                "IPv4Address": "172.25.0.2/16",
                "IPv6Address": ""
            },
            "990440a5202e10f2b168718fbbc4316b07643d1940e5c811d0c7d9503f9df6f7": {
                "Name": "wire_ngnix",

                "EndpointID": "26aae0dff008c5567d28d4b2959e6f73c65e867cdefae083cb4847687e67dc3b",
                "MacAddress": "5a:e6:7a:71:5c:ff",
                "IPv4Address": "172.25.0.3/16",
                "IPv6Address": ""
            }
        },
```

Now everything is complete, lets test our network.

# Testing

## Check if everything is set up

```bash
sudo wg-quick up wire_vpn
```

Check if all our required containers are running:

```bash
docker ps 

# Output
CONTAINER ID   IMAGE                     COMMAND                  CREATED        STATUS                       PORTS                                                                                              NAMES
990440a5202e   nginx                     "/docker-entrypoint.…"   19 hours ago   Up 3 minutes                 80/tcp                                                                                             wire-nginx
18974b2b2d8c   ghcr.io/wg-easy/wg-easy   "docker-entrypoint.s…"   19 hours ago   Up About an hour (healthy)   0.0.0.0:51820->51820/udp, [::]:51820->51820/udp, 0.0.0.0:51821->51821/tcp, [::]:51821->51821/tcp   wg-easy
```

Check if the `iptables` rules are intact:

```bash
route -n | grep 10.8.0.0

10.8.0.0        0.0.0.0         255.255.255.0   U     0      0        0 wire_vpn
```

Check your `wire_vpn` modified IPV4 address:

```bash
ip a | grep wire_vpn

# Output
18: wvpn: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 10.8.0.2/24 scope global wvpn
```

`10.8.0.2` will be the wire\_vpn tunnel ipv4 address.

## Make the `curl` request to NGINX container

*   `curl` with the `wire_vpn` interface:
    
    ```bash
    curl --interface 10.8.0.2 http://172.25.0.3
    
    # Expected output
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
    html { color-scheme: light dark; }
    body { width: 35em; margin: 0 auto;
    font-family: Tahoma, Verdana, Arial, sans-serif; }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>
    
    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>
    
    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    ```
    
    Here I explicitly used `--interface 10.8.0.2` flag, this forces `curl` to send the request through the WireGuard interface `10.8.0.2`. WIthout it, the request will go through your default network interface, which will be refused ofcourse.
    
*   `curl` with the `default physical network` interface:
    
    ```bash
    curl http://172.25.0.3
    
    # Output
    Timeout error
    ```
    
    This concludes the testing for our `covert_lan` .
    

# 🚀 Future Goals

Now this whole setup has opened the door for a bunch of fun experiments. Here’s what I’m planning next:

*   `Spin up an IDS/IPS container (Snort or Suricata)`: Drop it into promiscuous mode on the Docker network so it can sniff all traffic flowing between containers. The goal? Catch suspicious behavior — weird request patterns, port scans, anything shady — and log or alert on it.
    
*   `Create an attacker/scanner container (nmap, curl, etc.)`: Simulate real-world attacks from inside the covert LAN. This rogue container would try to port-scan, probe endpoints, or brute-force access — basically stress-testing the setup and helping me fine-tune firewall rules or detection systems.
    

This project is turning into my personal cyber lab, and I’m stoked to keep hacking on it. All thanks to Docker for its flexibility.

# Conclusion

What started as a workaround for my college network’s VPN restrictions turned into a full-on covert network experiment — and honestly, I learned a ton along the way.

By tunneling everything through WireGuard inside Docker, crafting tight `iptables` rules, and locking down access behind a `virtual LAN`, I now have an isolated environment where I can run services, test security, and explore without interference from the outside world.

It’s minimal, stealthy, and extremely modular — and that’s the beauty of it. This isn’t just a VPN setup; it’s the foundation for a private cyber playground. There’s plenty left to explore, from IDS/IPS integrations to automated rule orchestration and real-world service hosting.

If you're into self-hosting, network security, or just want to build something cool with Docker and WireGuard, give this a shot. Break things, tweak things, and make it your own.

The covert LAN awaits. 🕶️🛰️