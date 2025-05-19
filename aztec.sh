#!/bin/bash

echo -e "Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo -e "Installing dependencies..."
sudo apt install -y screen git curl net-tools psmisc jq ca-certificates

echo -e "Installing docker if not installed"
if ! command -v docker &>/dev/null; then
    echo -e "Docker not found. Installing Docker..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
	# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo -e "Docker successfully installed!"
else
    echo -e "Docker is installed"
fi

# Run docker as a user
echo -e "Configuring docker for non-root"
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER
sudo systemctl start docker


if [ -S /var/run/docker.sock ]; then
    sudo chmod 666 /var/run/docker.sock
fi

if docker info &>/dev/null; then
    echo -e "Docker is working for users"
else
    echo -e "Unable to configure docker for non root users"
    DOCKER_CMD="sudo docker"
fi

# If Aztec is already installed, remove it
[ -d $HOME/.aztec/alpha-testnet ] && rm -r $HOME/.aztec/alpha-testnet

# Install Aztec
curl -fsSL https://install.aztec.network | bash

if ! command -v $HOME/.aztec/bin/aztec &> /dev/null; then
  echo -e "Aztec not installed, exiting..."
  exit 1
fi

echo -e "Switching Aztec to alpha-testnet\n"
$HOME/.aztec/bin/aztec-up alpha-testnet

# Configuration
echo -e "Starting configuration, you will be asked some questions\n"
IP=$(curl -s https://api.ipify.org)
if [ -z "$IP" ]; then
    echo -e "Unable to find IP."
    read -p "Please enter your VPS/WSL IP address: " IP
fi


echo -e "Create a Sepolia RPC URL on dashboard.alchemy.com/apps and paste the URL here"
read -p "Enter Your Eth Sepolia Ethereum RPC URL: " l1_rpc_urls

echo -e "\nCreate an ETH Sepolia Beacon on drpc.org/"
read -p "Enter Your ETH Sepolia Beacon URL: " l1_consensus_host_urls 

echo -e "Create a new EVM wallet, then provide the wallet address and private key. Make sure you send some SepoliaETH to the associated wallet\n"
read -p "Enter the address of the wallet you just created: " wallet_address
read -p "Enter the private key you just created: " wallet_private_key


echo -e "Starting Aztec Alpha Node\n"
cat > $HOME/aztecnode.sh << EOL
#!/bin/bash
$HOME/.aztec/bin/aztec start --node --archiver --sequencer \\
  --network alpha-testnet \\
  --l1-rpc-urls $l1_rpc_urls \\
  --l1-consensus-host-urls $l1_consensus_host_urls \\
  --sequencer.validatorPrivateKey $wallet_private_key \\
  --sequencer.coinbase $wallet_address \\
  --p2p.p2pIp $IP
EOL

chmod +x $HOME/aztecnode.sh
screen -dmS aztec $HOME/aztecnode.sh

echo -e "Aztec node started successfully in a screen session. Type \nscreen -r aztec\n to view it\n"
