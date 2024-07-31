1. apro minikube
```
minikube start --listen-address='0.0.0.0' --apiserver-ips=192.168.2.154 --ports=8443:8443
```
2. modifico il config
```
server: https://192.168.2.154:8443
```
3. abilito l'addons per l'ingress con minikube
```
minikube addons enable ingress
```
4. creo deployment, service, ingress
5. apro tunnel minikube per esporre l'ingress
```
minikube tunnel
```
6. eseguo un curl per vedere se funziona
```
curl --resolve "test.example:80:127.0.0.1" -i http://test.example
```
    oppure su browser scrivo localhost:80
