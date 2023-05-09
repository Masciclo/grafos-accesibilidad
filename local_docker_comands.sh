
#see list of ports listening
sudo netstat -tulpn | grep LISTEN

# enter into containar
docker exec -it <container_id> /bin/bash

#inside the container
psql -U postgres initial_db 