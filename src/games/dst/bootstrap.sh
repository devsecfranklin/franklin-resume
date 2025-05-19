sudo apt install podman containers-storage docker-compose -y                                                                  
sudo tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'                                                                    
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam               
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam           
EOF                                                                                                                           
sudo dpkg --add-architecture i386                                                                                             
sudo apt-get update                                                                                                      
sudo apt-get install \                                                                                                   
  libgl1-mesa-dri:amd64 \                                                                                                
  libgl1-mesa-dri:i386 \                                                                                                
  libgl1-mesa-glx:amd64 \                                                                                               
  libgl1-mesa-glx:i386 \                                                                                                
  steam-launcher                                                                                                        
                                                                                                                         
sudo useradd -d /home/dst -g 60 -m -s /bin/bash -u 6969 dst                                                              
                                                                                                                         
sudo git clone https://github.com/mathielo/dst-dedicated-server.git /opt/dst-dedicated-server                             
sudo chown -R dst:games /opt/dst-dedicated-server                                                                             
dst@games:~$ vi bootstrap.sh 
dst@games:~$ cat bootstrap.sh 
sudo DEBIAN_FRONTEND=noninteractive apt-get install podman containers-storage docker-compose -y
sudo tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF
sudo dpkg --add-architecture i386
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  libgl1-mesa-dri:amd64 \
  libgl1-mesa-dri:i386 \
  libgl1-mesa-glx:amd64 \
  libgl1-mesa-glx:i386 \
  steam-launcher

# add to games group
sudo useradd -d /home/dst -g 60 -m -s /bin/bash -u 6969 dst

# clone the dst repo and put in /opt
sudo git clone https://github.com/mathielo/dst-dedicated-server.git /opt/dst-dedicated-server
sudo chown -R dst:games /opt/dst-dedicated-server

