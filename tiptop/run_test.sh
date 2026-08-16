#!/usr/bin/env bash
set -euo pipefail

SERVER_CONTAINER="clab-tiptop-h3-server-quiche"
CLIENT_CONTAINER="clab-tiptop-h3-client-quiche"
SERVER_CMD="./server"
CLIENT_CMD="./client https://http3.space:4433/bigfile.txt"
TCPDUMP_CMD="tcpdump -i eth1 -w /app/client.pcap"

cleanup() {
    echo "Cleaning up server and client states ..."
    docker exec -it $SERVER_CONTAINER pkill -f "$SERVER_CMD"
    docker exec -it $CLIENT_CONTAINER rm -f /app/client.pcap
    docker exec -it $CLIENT_CONTAINER rm -f /app/metrics.log
    docker exec -it $CLIENT_CONTAINER rm -rf /qlog/*
    docker exec -it $SERVER_CONTAINER rm -rf /qlog/*
    echo "Done. Exiting"
}
trap cleanup EXIT

docker exec -d $CLIENT_CONTAINER $TCPDUMP_CMD
echo "Started packet capture on client container"

docker exec -d $SERVER_CONTAINER $SERVER_CMD
echo "Started server in ${SERVER_CONTAINER}"

sleep 1

echo "Running client in ${CLIENT_CONTAINER} ..."
docker exec $CLIENT_CONTAINER $CLIENT_CMD
docker exec -it $CLIENT_CONTAINER pkill -f "$TCPDUMP_CMD"

echo "Client process finished"
echo "Transferring metrics and qlog files from server and client containers ..."

METRICS_DIR="metrics_$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p $METRICS_DIR
mkdir -p $METRICS_DIR/qlog

docker cp $CLIENT_CONTAINER:/app/metrics.log $METRICS_DIR/metrics.log
docker cp $CLIENT_CONTAINER:/qlog/. $METRICS_DIR/qlog
docker cp $SERVER_CONTAINER:/qlog/. $METRICS_DIR/qlog

docker cp $CLIENT_CONTAINER:/app/client.pcap $METRICS_DIR/client.pcap
echo "Metrics and qlog files transferred to ${METRICS_DIR}"

echo "Copying config.json into metrics directory ..."
cp configs/config.json $METRICS_DIR/config.json
