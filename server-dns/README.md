Dopo aver eseguito il comando "vagrant up" e dopo aver impostato il server dns come primario,
eseguire i seguenti comandi per verificare che il server dns funzioni correttamente:

nslookup route-oca-base-fe-paolucci.apps.okd.devops.lab
dig @192.168.56.21 route-oca-base-fe-paolucci.apps.okd.devops.lab
curl -k https://route-oca-base-fe-paolucci.apps.okd.devops.lab:443
