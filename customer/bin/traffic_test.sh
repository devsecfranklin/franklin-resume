# does ip command exist

# does ifconfig cmd exist


# check ICMP

cat /proc/sys/net/ipv4/icmp_echo_ignore_all # It should output 0 which means ping is enabled, i.e. IPv4 ICMP echo request is not ignored.
# sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0 # fix ICMP
# cat /etc/sysctl.conf # net.ipv4.icmp_echo_ignore_all=0 line should exist


# find route command
# get the routes
route -n

# TCPDUMP

# use the -w flag to save to a file name

which tcpdump
sudo tcpdump -D
#sudo tcpdump --interface ens5
#sudo tcpdump -i ens5 -c 5
sudo tcpdump -i ens5 -c5 icmp # filter by protocol
#sudo tcpdump -i any -c5 -nn host 54.204.39.132 # Limit capture to only packets related to a specific host by using the host filter
sudo tcpdump -i any -c5 -nn src 10.236.20.20 # capture packets from a specific host
