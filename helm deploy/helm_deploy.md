Creare un Helm Chart custom che effettui il deploy dell'immagine creata tramite la pipeline flask-app-example-build (in input deve essere possibile specificare quale tag rilasciare)

Scrivere pipeline dichiarativa Jenkins che prenda da GIT il repo chart versionato ed effettui "helm install" sull'instanza K8s locale su namespace "formazione_sou"

Autenticandosi tramite un Service Account di tipo "cluster-reader" (studiare bene RBAC di k8s)  esegua un export del Deployment dell'applicazione Flask installata tramite la Track 3. E' possibile scegliere tra: utilizzo API k8s (modulo python kubernetes, wrapping di kubectl (es: kubectl get deployment foobar -o yaml -n formazione_sou), wrapping di curl (sempre verso le API)
L'automatismo deve ritornare un errore se non presenti nel Deployment i seguenti attributi: Readiness e Liveness Probles, Limits e Requests.

Svolgimento:

1. Installo helm con "brew install helm" e creo un chart con "helm create myapp"
2. Personalizzo il chart:
   - nel file "values.yaml" vado a definire l'immagine
     ```
     image:
      repository: federicopao/formazione_sou_k8s
      pullPolicy: IfNotPresent
      # Overrides the image tag whose default is the chart appVersion.
      tag: "latest"
     ```
     il tipo di service
     ```
     service:
      type: NodePort
      port: 5000
     ```
     setto il delay iniziale per il liveness e per il readness probe in modo che possa eseguire il deploy senza andare in errore
     ```
     livenessProbe:
      initialDelaySeconds: 100
      httpGet:
        path: /
        port: http
     readinessProbe:
      initialDelaySeconds: 100
      httpGet:
        path: /
        port: http
     ```
   - per creare e dare i permessi al service account creo i seguenti oggetti
     https://github.com/federicopao/formazione_sou/helm deploy/charts/myapp/serviceaccount.yaml
     https://github.com/federicopao/formazione_sou/helm deploy/charts/myapp/clusterrole.yaml (permessi di lettura)
     https://github.com/federicopao/formazione_sou/helm deploy/charts/myapp/clusterrolebinding.yaml
     https://github.com/federicopao/formazione_sou/helm deploy/charts/myapp/secret.yaml (per creare il token del service account)

3. Eseguo il push del chart su github

4. Installo minikube con "brew install minikube", creo il cluster con
   ```
   minikube start --listen-address='0.0.0.0' --apiserver-ips=192.168.2.154 --ports=8443:8443
   ```
   --listen-address mette il cluster in ascolto sull'ip specificato
   
   --apiserver-ips=192.168.2.154 crea i certificati su questo ip
   
   --ports mappa le porte del cluster con quelle di minikube
   
5. Modifico il kube config con l'ip sopra indicato
   ```
   server: https://192.168.2.154:8443
   ```
6. Creo il vagrantfile e il playbook di Ansible per creare e configurare la macchina virtuale che con jenkins andrà a comunicare con
   il cluster

   - nel file ansible mi copio i certificati, il kube config e l'immagine da buildare, poi fornisco i permessi necessari in modo che
     jenkins possa accedere ai certificati
7. L'immagine personalizzata di jenkins mi copia.... mi installa...
   
