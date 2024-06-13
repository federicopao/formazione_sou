```ruby
#!/bin/bash
# am-i-root.sh:   Am I root or not?
 
ROOT_UID=0   # Root has $UID 0.

# If the current user ID (UID) is zero(ROOT_UID), the user is root 
if [ "$UID" -eq "$ROOT_UID" ]  # Will the real "root" please stand up?
then
  # The condition is true
  echo "You are root."
else
  # The condition is false
  echo "You are just an ordinary user (but mom loves you just the same)."
fi

# terminate the process and return zero
exit 0

 
# ============================================================= #
# Code below will not execute, because the script already exited.
 
# An alternate method of getting to the root of matters:
 
ROOTUSER_NAME=root

# The command id -nu return the name of the user
username=`id -nu`              # Or...   username=`whoami`

# Check if the user name is root
if [ "$username" = "$ROOTUSER_NAME" ]
then
  echo "Rooty, toot, toot. You are root."
else
  echo "You are just a regular fella."
fi
```
