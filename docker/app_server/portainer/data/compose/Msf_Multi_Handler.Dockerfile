# Metasploit Listener - HTTP(S) for prices.
# Rolling Kali OS running a Metasploit (MSF) web port listener. 
# Customize listener configuration using environment variables, if necessary.
FROM docker.io/kalilinux/kali-rolling

#
ENV LPORT_HTTPS=443 LPORT_WIN=4444 LPORT_LIN_86=6444 LPORT_LIN_64=8444
#

RUN export DEBIAN_FRONTEND=noninteractive
# Update and install dependencies
RUN apt-get update && \
    apt-get install -y metasploit-framework openssh-server && \
    apt-get clean
# Set the working directory
WORKDIR /root
# Start the web listener
ADD multi_handler.rc "/opt/msf_rc/multi_handler.rc"
EXPOSE $LPORT_HTTPS $LPORT_WIN $LPORT_LIN_86 $LPORT_LIN_64

# Start msfconsole with a resource script to set up the listener
CMD ["msfconsole"]
