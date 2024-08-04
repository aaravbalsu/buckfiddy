# buckfiddy
Easily spin up red team infrastructure on the cheap!

Developed by: Aarav Balsu (ping00) and George Polivka (soxballs)

## Project Goals
This project aims to develop a suite of components that a red team might use on engagements. This set of infrastructure can be deployed (and torn down!) in minutes using Terraform on Azure, focusing on minimal cost, secure networking between components and leveraging open-source technologies throughout.

## Technologies Used
### Infrastructure Substrate
- Terraform
- Azure (the goal is to get this tool ported to AWS and GCP in the future)
- Docker

### Networking Substrate
- Tailscale / Headscale
- Nginx

### Authentication / SSO Substrate
- Keycloak

### Application substrate
- Homarr (dashboard)
- PrivateBin (Pastebin)
- Gitea (Code management)
- Ghostwriter (Reporting)

### Pentesting substrate
- Sliver server installation
- Metasploit handler
- Kali VMs (x3)

# Setup Instructions
1. Clone the repository:
   `git clone https://github.com/aaravbalsu/buckfiddy`

2. Check out the [wiki](https://github.com/aaravbalsu/buckfiddy/wiki) to get started! 
