#! /bin/zsh

date1=$(date +%s)

# Struttura ad albero per le cartelle
# 10^3 + 10^2 + 10^1 + radice "test" = 1111 cartelle
mkdir -p test/{0..9}/{0..9}/{0..9}
for i in {0..100};
do
  for d in **/*(/); do dd if=/dev/random  bs=1024 count=40 2>/dev/null|base64 >"$d/t"$i"" && truncate -s 40K "$d/t"$i""; done

  # per shell bash usare ../. oppure abilitare * con il comando shopt:
  # shopt -s globstar
  # for d in **/*/; do touch -- "$d/file"; done
done

# comprimo, invio sulla vm, decomprimo sulla vm in ssh
tar -cjf test.tar.bz2 test
scp -r /Users/federico/esercizio/test.tar.bz2 utente1@192.168.39.130:/home/utente1
ssh utente1@192.168.39.130 "tar -xjf test.tar.bz2"

date2=$(date +%s)
echo $(($date2-$date1))

p=/Users/federico/esercizio/test/
cd /Users/federico/esercizio/test

for j in {0..5}
do

  cd /Users/federico/esercizio/test
  # variabile usata per indicare il path del file che andrà modificato
  p=/Users/federico/esercizio/test/
  # usata per scegliere il livello di profondità dell'albero
  rdmdir=$((RANDOM % 3))
  # variabile che seleziona quale dei 100 file nella cartella selezionata dovrà essere modificato  
  rdmfile=$((RANDOM % 99))

    # se il livello è diverso da 0 bisogna creare il path
    if [ "$rdmdir" != "0" ]
    then
      for x in {0..$rdmdir};
      do
        #per ogni livello ho diverse cartelle tra cui scegliere, ogni livello ha 10^(numero di livello) directory in cui scendere
        rdmdir2=$((RANDOM % 3))
        p="$p$rdmdir2"/
      done
    fi

  echo $p
  echo "$p"t"$rdmfile"

  #modifico il file
  cat /dev/null > "$p"t"$rdmfile"

done

#aggiorno i dati sulla vm con le modifiche apportate
#rsync sovrascrive solo i file aggiornati
rsync -av /Users/federico/esercizio/test/ utente1@192.168.39.130:/home/utente1/test/
