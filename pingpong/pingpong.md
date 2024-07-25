Creare un progetto Vagrant a due nodi Linux con dentro Docker.
Solamente un nodo alla volta deve girare il container https://hub.docker.com/r/ealen/echo-server Ogni 60 secondi, il container deve migrare sul nodo "scarico". Questo significa che il container è come se facesse ping pong da un nodo all'altro.
Potete utilizzare quello che volete, soluzioni particolari con Bash, orchestratori di container, Jenkins, linguaggi vari. Lo scopo dell'attività non è puramente tecnico.
Si vuole testare la capacità di trovare soluzione anche temporanee ma funzionanti.

Svolgimento:
```
```
1. Creo la cartella per inizializzare vagrant con il comando "vagrant init"
2. nel Vagrantfile configuro i due nodi
   ```
     N = 2
     (1..N).each do |i|

       config.vm.define "node#{i}" do |node|
         node.vm.hostname = "node#{i}"
         node.vm.network "private_network", ip: "192.168.56.#{20+i}"
       end
   
     end
   ```
3. sempre nel Vagrantfile aspetto che entrambe le macchine virtuali siano pronte per eseguire il file di ansible
   ```
   if i == N
        node.vm.provision "ansible" do |ansible|
          # Disable default limit to connect to all the machines
          ansible.limit = "all"
          ansible.playbook = "playbook.yml"
          ansible.become = true
          ansible.compatibility_mode = "2.0"
        end
   ```
4. creo il file per ansible "playbook.yml". Ansible crea ed esegue il run del container contenente l'immagine sopra indicata su entrambe
   le macchine virtuali.
   sulla vm nominata node1 viene fatto il kill del container, abbiamo ora che su node2 gira il container e invece su node1 no.
   Da questo momento aspetto 60 secondi e poi eseguo le seguenti tasks
   ```
   - hosts: node2
     become: yes
     tasks:
      - name: crontab2
        cron:
           name: c2
           minute: "*/2"
           job: "sudo -i docker kill container && sleep 60 && sudo -i docker start container"
       
   - hosts: node1
     become: yes
     tasks:
      - name: crontab1
        cron:
           name: c1
           minute: "*/2"
           job: "sudo -i docker start container && sleep 60 && sudo -i docker kill container"
   ```
   Il primo tasks con l'opzione cron esegue ogni due minuti (minute: "*/2") il job sul node2:
   "sudo -i docker kill container && sleep 60 && sudo -i docker start container"

   Il secondo tasks con l'opzione cron esegue ogni due minuti (minute: "*/2") il job sul node1:
   "sudo -i docker start container && sleep 60 && sudo -i docker kill container"

   Può essere così illustrato:

   ![Immagine 25-07-24 - 14 07](https://github.com/user-attachments/assets/821614a0-1c6f-4118-9ebd-92aef238305c)

5. Eseguo il comando "vagrant up" dentro la cartella inizializzata al punto 1
