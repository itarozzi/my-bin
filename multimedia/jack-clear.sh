#! /bin/sh

# Clear pending jack and ladi process
# This script should be executed before jackd starts
# You can use qjackctl GUI to execute it

killall -9 ladishd
killall -9 jackd
killall -9 jackdbus
pulseaudio -k

echo "Jack Clear complete!"
sleep 3

echo "Jack Clear complete!"
