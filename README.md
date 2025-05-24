# aztec-sequencer
Script to run an Aztec Sequencer

# How to run
## Download & execute the script
```sh
wget -O aztec.sh https://raw.githubusercontent.com/on-blockchain/aztec-sequencer/main/aztec.sh && chmod +x aztec.sh && ./aztec.sh
```

If everything is successful, the node will run in a screen called aztec, you can view it using:
```sh
screen -r aztec
```

If you restart the server or the sequencer stops, you can re-run it using
```sh
screen -dmS aztec $HOME/aztecnode.sh
```

# Additional Ressources
You will need faucet, you can mine it here:
```
https://sepolia-faucet.pk910.de/
```

RPC - Alchemy:
```https://dashboard.alchemy.com/```

Beacon - DRPC
```https://drpc.org/```
