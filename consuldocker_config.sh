# A Bootstrap server: 10.134.4.147 #10.134.4.144
docker pull progrium/consul
docker rm --force `docker ps -qa`
export prvip=$(/sbin/ip -o -4 addr list eth1 | grep brd | awk '{print $4}' | cut -d/ -f1)
export pubip=$(/sbin/ip -o -4 addr list eth0 | grep brd | awk '{print $4}' | cut -d/ -f1)
docker run -d -h `hostname` -v /mnt:/data \
    -p $prvip:8300:8300 \
    -p $prvip:8301:8301 \
    -p $prvip:8301:8301/udp \
    -p $prvip:8302:8302 \
    -p $prvip:8302:8302/udp \
    -p $prvip:8400:8400 \
    -p $prvip:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -server -advertise $prvip -bootstrap-expect 3

# Execute shell inside Bootstrap docker process
sudo docker exec -i -t `docker ps | grep progrium | sed -e 's/[[:blank:]]\{2,\}\+/\t/g' | cut -f 7` sh

# Other servers joining to the Bootstrap server 
docker pull progrium/consul
docker rm --force `docker ps -qa`
export prvip=$(/sbin/ip -o -4 addr list eth1 | grep brd | awk '{print $4}' | cut -d/ -f1)
export pubip=$(/sbin/ip -o -4 addr list eth0 | grep brd | awk '{print $4}' | cut -d/ -f1)
docker run -d -h `hostname` -v /mnt:/data  \
    -p $prvip:8300:8300 \
    -p $prvip:8301:8301 \
    -p $prvip:8301:8301/udp \
    -p $prvip:8302:8302 \
    -p $prvip:8302:8302/udp \
    -p $prvip:8400:8400 \
    -p $prvip:8500:8500 \
    -p 172.17.0.1:53:53/udp \
    progrium/consul -server -advertise $prvip -join 10.134.4.147 #10.134.4.144

# Client Web UI agent
cd ~
wget https://dl.bintray.com/mitchellh/consul/0.3.0_web_ui.zip
unzip *.zip
rm *.zip

export pubip=$(/sbin/ip -o -4 addr list eth0 | grep brd | awk '{print $4}' | cut -d/ -f1)
consul agent -data-dir /tmp/consul -advertise $pubip -client $pubip -ui-dir /root/dist -join 10.134.4.147 #10.134.4.144

