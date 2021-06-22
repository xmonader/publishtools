set -ex
echo 1 > log.txt
sudo apt install redis-server -y
sudo /etc/init.d/redis-server start

# bash install.sh   # the docker already has v binaries in /opt/vlang/v

v install patrickpissurno.redis
v install despiegk.crystallib
v install nedpals.vex

bash build.sh
echo 2 >> log.txt
echo 3 >> log.txt
set +ex
# publishtools flatten
# echo 4 >> /tmp/log.txt
# publishtools flatten
# echo 5 >> /tmp/log.txt



