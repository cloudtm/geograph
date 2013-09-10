ps -p`cat ~/geograph-track-provider/tmp/pids/server.pid` >/dev/null
res=$?
if [ "$res" = "1" ]; then
    echo "Geograph track provider is not running"
else
    echo "Geograph track provider IS RUNNING"
fi
