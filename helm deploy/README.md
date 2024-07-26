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
     
     https://github.com/federicopao/formazione_sou/tree/main/helm%20deploy/myapp/templates/serviceaccount.yaml
     https://github.com/federicopao/formazione_sou/tree/main/helm%20deploy/myapp/templates/clusterrole.yaml (permessi di lettura)
     https://github.com/federicopao/formazione_sou/tree/main/helm%20deploy/myapp/templates/clusterrolebinding.yaml
     https://github.com/federicopao/formazione_sou/tree/main/helm%20deploy/myapp/templates/secret.yaml (per creare il token del service account)

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
     
7. L'immagine personalizzata di jenkins installa tutto quello di cui ho bisogno per svolgere l'esercizio:
   - docker
   - helm
   - jq
   - kubectl
   copio nell'immagine il kube config e i certificati passati nella vm da Ansible

8. Eseguo il "vagrant up" per creare e configurare la macchina virtuale con un container contenente l'immagine jenkins personalizzata,
   ora abbiamo la vm con i permessi configurati per poter accedere al cluster in ascolto.
   Apro il browser inserendo l'ip della vm con la porta 8080 per potermi connettere alla dashboard di jenkins che da repository git si
   prende il jenkins file contenente la pipeline da eseguire
   (https://github.com/federicopao/formazione_sou/blob/main/helm%20deploy/jenkinsfile)

9. La pipeline esegue il git clone della repoitory contenente l'helm chart e tutti i file necessari per svolgere l'esercizio
   ```
   sh "git clone https://github.com/federicopao/formazione_sou.git"
   ```
   esegue l'helm install del chart
   ```
   sh "helm install myappname11 ./formazione_sou/charts/myapp"
   ```
   esegue l'export del deployment autenticandosi con un service account ed esegue uno script per verificare che i campi specificati
   nel testo dell'esercizio non siano vuoti
   ```
   script {
                    
                    def APISERVER = sh(script: "kubectl config view --minify | grep server | cut -f 2- -d ':' | tr -d ' '", returnStdout: true).trim()
                    # Richiedo al cluster il token associato al service account per potermi autenticare nel curl
                    def TOKEN = sh(script: "kubectl describe secret explorer-token | grep -E '^token' | cut -f2 -d':' | tr -d ' '", returnStdout: true).trim()
                    # Richiedo all'apiserver il file yaml del deployment salvandolo in un file json
                    sh(script: "curl ${APISERVER}/apis/apps/v1/namespaces/default/deployments/myappname11 --header 'Authorization: Bearer ${TOKEN}' --insecure -o deployment.json")
        
                    sh(script: "./formazione_sou/script.sh")
   }
   ```
   nello script interrogo il file json con il comando jq
   ```
   HAS_LIVENESS_PROBE=$(jq '.spec.template.spec.containers[] | select(has("livenessProbe")) | .name' deployment.json)

   HAS_READINESS_PROBE=$(jq '.spec.template.spec.containers[] | select(has("readinessProbe")) | .name' deployment.json)
   
   HAS_LIMITS=$(jq '.spec.template.spec.containers[] | select(has("limits")) | .name' deployment.json)
   
   HAS_REQUESTS=$(jq '.spec.template.spec.containers[] | select(has("requests")) | .name' deployment.json)
   if [ -z "$HAS_LIVENESS_PROBE" ] || [ -z "$HAS_READINESS_PROBE" ] || [ -z "$HAS_LIMITS" ] || [ -z "$HAS_REQUESTS" ]; then
     echo "ERROR"
   else
     echo "SUCCESS"
   fi
   ```
