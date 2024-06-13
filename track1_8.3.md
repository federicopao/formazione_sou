```ruby
#!/bin/bash
 
# Call this script with at least 10 parameters, for example
# ./scriptname 1 2 3 4 5 6 7 8 9 10
MINPARAMS=10
 
echo
#$0 is the name of thew script
echo "The name of this script is \"$0\"."
# Adds ./ for current directory
echo "The name of this script is \"`basename $0`\"."
# Strips out path name info (see 'basename')
 
echo
# Check if the parameter is not empty
if [ -n "$1" ]              # Tested variable is quoted.
then
 # If the parameter is not empty print it
 echo "Parameter #1 is $1"  # Need quotes to escape #
fi
 
if [ -n "$2" ]
then
 echo "Parameter #2 is $2"
fi
 
if [ -n "$3" ]
then
 echo "Parameter #3 is $3"
fi
 
# ...
 
#parameters over 9 must be enclosed in brackets because echo $10 could be "value of $1"0 
if [ -n "${10}" ]  # Parameters > $9 must be enclosed in {brackets}.
then
 echo "Parameter #10 is ${10}"
fi
 
echo "-----------------------------------"
# $* is an array with all parameter
echo "All the command-line parameters are: "$*""

# $# is the number of the parameters insert by the user
if [ $# -lt "$MINPARAMS" ]
then
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
fi 
 
echo
 
exit 0
```
