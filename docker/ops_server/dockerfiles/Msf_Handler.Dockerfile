# Metasploit Listener - HTTP(S) for prices.
# Rolling Kali OS running a Metasploit (MSF) web port listener. 
# Customize listener configuration using environment variables, if necessary.
FROM kalilinux/kali-rolling

#
ENV LPORT_HTTPS=443 LPORT_WIN=4444 LPORT_LIN_86=6444 LPORT_LIN_64=8444
#

RUN export DEBIAN_FRONTEND=noninteractive
# Update and install dependencies
RUN apt update && \
    apt install -y metasploit-framework && \
    apt clean
# Set the working directory
WORKDIR /root
# Expose appropriate ports
EXPOSE $LPORT_HTTPS $LPORT_WIN $LPORT_LIN_86 $LPORT_LIN_64

# Start msfconsole as an entrypoint
ENTRYPOINT ["msfconsole", "-r", "/opt/msf_rc/handler.rc"]
