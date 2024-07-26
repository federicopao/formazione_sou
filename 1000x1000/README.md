Creare una struttura di almeno 1000 cartelle (4 livelli) ognuna contenente 1000 file da almeno 40kb di testo randomico.
Spostare le proprie cartelle utilizzando scp su una vm. salvare il tempo di esecuzione. modificare 100 file random, trasportare le modifiche su vm usando un solo comando

Svolgimento:

1. Realizzo un albero di ricerca bilanciato ricorsivamente per ottimizzare i tempi di creazione della struttura dati
   ```
   # 10^3 + 10^2 + 10^1 + radice "test" = 1111 cartelle
   mkdir -p test/{0..9}/{0..9}/{0..9}
   ```
2. Dopo aver creato la struttura dati utilizzo il seguente comando per popolare l'intero albero partendo dalla radice
   ```
   for d in **/*(/); do dd if=/dev/random  bs=1024 count=40 2>/dev/null|base64 >"$d/t"$i"" && truncate -s 40K "$d/t"$i""; done

   #per shell bash usare ../. oppure abilitare * con il comando shopt:
   #shopt -s globstar
   #for d in **/*/; do touch -- "$d/file"; done
   ```
   Per popolare ogni nodo dell'albero con più di un file ripetere l'operazione:
   ```
   for i in {0..100};
   do
     for d in **/*(/); do dd if=/dev/random  bs=1024 count=40 2>/dev/null|base64 >"$d/t"$i"" && truncate -s 40K "$d/t"$i""; done
   done
   ```
   Abbiamo ora la nostra struttura dati popolata da 100 file randomici per ogni nodo dell'albero.
   I file e le cartelle sono identificate da numeri:
   per le cartelle 1,2,3,...
   per i file t1,t2,t3,...

4. bisogna spostare ora tutto l'albero con i file su una vm, per farlo compriamo la struttura e usiamo il comando scp per spostare
   il file sulla vm per poi decomprimere in ssh
   ```
   tar -cjf test.tar.bz2 test
   scp -r /Users/federico/esercizio/test.tar.bz2 utente1@192.168.39.130:/home/utente1
   ssh utente1@192.168.39.130 "tar -xjf test.tar.bz2"
   ```
5. Per monitorare il tempo di esecuzione ho preso la data di inizio e di fine esecuzione per poi sottrarle
   ```
   date1=$(date +%s)
   # ...
   date2=$(date +%s)
   echo $(($date2-$date1))
   ```
6. Per modificare 1 file random mi sposto nella radice e setto tre variabili in modo, una da usare per inserire il path della cartella
   del file che dovrà essere modificato, una per scegliere la profondità dell'albero, una per scegliere quale dei 100 file nella
   cartella scelta dovrà essere modificato.

   Se il livello dell'albero è uguale a 0 allora in base alla variabile rdmfile modifico uno dei 100 file presenti nella radice.
   Se il livello è diverso da zero devo creare il path che mi permette di arrivare in modo randomico al livello desiderato.
   una volta che ho il path della cartella e il numero che mi identifica quale dei 100 file in quella directory voglio modificare,
   lo modifico.

   se voglio modificare 100 file utilizzo un file ricordandomi la condizione iniziale, al termine di ogni modifica ritorno nella radice
   
   ```
   for j in {0..100}
   do

     cd /Users/federico/esercizio/test
     p=/Users/federico/esercizio/test/

     #scelgo la profondità a cui arrivare
     rdmdir=$((RANDOM % 3))
     #scelgo quale dei 100 file modificare nella directory scelta
     rdmfile=$((RANDOM % 30))

       #se il livello è diverso da zero devo creare il path per arrivarci
       if [ "$rdmdir" != "0" ]
       then
         for x in {0..$rdmdir};
         do
           #per ogni livello ho diverse cartelle tra cui scegliere, ogni livello ha 10^(numero di livello) directory in cui scendere
           rdmdir2=$((RANDOM % 10**x-1))
           p="$p$rdmdir2"/
         done
       fi
  
     echo $p
     echo "$p"t"$rdmfile"
  
     #modifico il file
     cat /dev/null > "$p"t"$rdmfile"
   
   done
   ```
7. Per aggiornare le modifiche sulle vm uso il comando rsync che aggiorna solo le modifiche
   ```
   rsync -av /Users/federico/esercizio/test/ utente1@192.168.39.130:/home/utente1/test/
   ```
