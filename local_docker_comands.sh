# enter into containar
docker exec -it <container_id> /bin/bash

#see list of ports listening
sudo netstat -tulpn | grep LISTEN