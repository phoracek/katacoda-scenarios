while true; do
    for node_container_id in $(docker ps | grep kind | cut -d' ' -f1); do
        docker exec $node_container_id sh -c '
for unavailable_iface in $(nmcli d | grep unavailable | cut -d" " -f1); do
    ip link set $unavailable_iface up
done
'
    done

    sleep 1
done
