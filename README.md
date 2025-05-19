# aztec-sequencer
Script to run an Aztec Sequencer

# How to run
## Download & execute the script
```sh
wget -qO- https://raw.githubusercontent.com/on-blockchain/aztec-sequencer/main/aztec.sh | bash
```

If everything is successful, the node will run in a screen called aztec

If you restart the server or the sequencer stops, you can re-run it using
```sh
screen -dmS aztec $HOME/aztecnode.sh
```
