"""Check Pass."""

#from subprocess import call

with open('/keybase/private/frankthetank/pass.txt') as input_file:
  for i, line in enumerate(input_file):
    print("Checking...")
    proc = Popen(["ssh-add","~/.ssh/id_rsa.pub"], stdin=PIPE,stdout=PIPE,stderr=PIPE)
    time.sleep(1)
    proc.stdin.write(i)
    time.sleep(1)
