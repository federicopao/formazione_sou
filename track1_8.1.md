```ruby
# Cleanup
# Run as root, of course.

cd /var/log

# I use cat /dev/null to overwrite the two log files
# but /dev/null is empty, so now the log is cleaned!
cat /dev/null > messages
cat /dev/null > wtmp

echo "Log files cleaned up."
```
