#! /bin/zsh

date1=$(date +%s)

#I create a balanced search tree recursively
mkdir -p test/{0..5}/{0..5}/{0..5}
for i in {0..30};
do
  #for each node I create a random file
  #repeat this action if you want more file in each node
  #for bash use:
  #shopt -s globstar
  #for d in **/*/; do touch -- "$d/file"; done
  for d in **/*(/); do dd if=/dev/random  bs=1024 count=40 2>/dev/null|base64 >"$d/t"$i"" && truncate -s 40K "$d/t"$i""; done
done

tar -cjf test.tar.bz2 test
scp -r /Users/federico/esercizio/test.tar.bz2 utente1@192.168.39.130:/home/utente1
ssh utente1@192.168.39.130 "tar -xjf test.tar.bz2"

date2=$(date +%s)
echo $(($date2-$date1))

p=/Users/federico/esercizio/test/
cd /Users/federico/esercizio/test

for j in {0..5}
do
  #set two variable, one for the path of the directory, one for choose the file in the directory
  rdmdir=$((RANDOM % 3))
  rdmfile=$((RANDOM % 30))

    if [ "$rdmdir" != "0" ]
    then
      for x in {0..$rdmdir};
      do
        rdmdir2=$((RANDOM % 3))
        p="$p$rdmdir2"/
      done
    fi

  echo $p
  echo "$p"t"$rdmfile"

  #modify the file
  cat /dev/null > t"$rdmfile"

  #return at the main path
  cd /Users/federico/esercizio/test

  p=/Users/federico/esercizio/test/
done

#rsync overwrite only the modify files
rsync -av /Users/federico/esercizio/test/ utente1@192.168.39.130:/home/utente1/test/
