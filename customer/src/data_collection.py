"""Data Collection."""

import paramiko
import getpass
import time
from pprint import pprint

# HOSTNAME = '10.10.10.1'  #Firewalls IP
# HOSTNAME = "panorama1.dead10c5.org"
HOSTNAME = "156.134.194.147"
PORT = 22


def log_collector(username, password):
    """
    log_collector.

    Args:
    ----
        username (_type_): _description_
        password (_type_): _description_

    """
    cmd = "show log-collector connected"
    ssh_command(username, password, cmd)


def ssh_command(username, password, cmd, hostname=HOSTNAME, port=PORT):
    """
    ssh_command.

    Args:
    ----
        username (_type_): _description_
        password (_type_): _description_
        cmd (_type_): _description_
        hostname (_type_, optional): _description_. Defaults to HOSTNAME.
        port (_type_, optional): _description_. Defaults to PORT.

    """
    ssh_client = paramiko.SSHClient()
    #ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.load_system_host_keys()
    ssh_client.connect(hostname, port, username=username, password=password)
    remote_conn = ssh_client.invoke_shell()
    print("Interactive SSH session established")
    remote_conn.send("set cli pager off\n")
    # > set cli scripting-mode on
    time.sleep(5)
    # remote_conn.send("debug cli on\n")
    # time.sleep(5)
    remote_conn.send(cmd + "\n")
    time.sleep(5)

    buff = ""

    while not str(buff).endswith(")> "):
        resp = remote_conn.recv(9999)
        buff += resp.decode("utf-8")
        pprint("buff: " + resp.decode("utf-8"))

    # save the results to disk
    file1 = open("/tmp/palo/buff.txt", "w")
    file1.write(buff)
    file1.close()

    # completed
    print("done")


if __name__ == "__main__":
    """main."""
    try:
        username = input("Enter username: ")
        password = getpass.getpass(prompt="Enter password: ", stream=None)
    except Exception as e:
        print(e)

    log_collector(username, password)
