# Import dependencies

import subprocess
import json
from dotenv import load_dotenv
import os
from web3 import Web3
from web3.middleware import geth_poa_middleware 
from eth_account import Account
from bit import PrivateKeyTestnet, PrivateKey
from bit.network import NetworkAPI


# Load and set environment variables
load_dotenv()
mnemonic=os.getenv("mnemonic")

# Import constants.py and necessary functions from bit and web3
# YOUR CODE HERE
from constants import *
 
# Create a function called `derive_wallets`
def derive_wallets(coin):
    command = f'php ./derive -g --mnemonic="{mnemonic}" --cols=path,address,privkey,pubkey --coin={coin} --numderive=1 --format=json'
    p = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    output, err = p.communicate()
    p_status = p.wait()
    return json.loads(output)
    


# Create a dictionary object called coins to store the output from `derive_wallets`.
coins = {BTC:derive_wallets(BTC), ETH:derive_wallets(ETH), BTCTEST:derive_wallets(BTCTEST)}
# Create a function called `priv_key_to_account` that converts privkey strings to account objects.

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)
def priv_key_to_account(coin_output):
    # YOUR CODE HERE
    private_key = coins[coin_output]['privkey']
    if coin_output==ETH:
        account = Account.from_key(private_key)
    elif coin_output ==BTC:
        account = PrivateKey(private_key)
    else:
        account = PrivateKeyTestnet(private_key)
    return account

# Create a function called `create_tx` that creates an unsigned transaction appropriate metadata.
def create_tx(coin, account, recipient, amount):
    # YOUR CODE HERE
    if coin ==ETH:
        gasEstimate = w3.eth.estimateGas(
        {"from": account.address, "to": recipient, "value": amount}
        )
        return {
            "from": account.address,
            "to": recipient,
            "value": amount,
            "gasPrice": w3.eth.gasPrice,
            "gas": gasEstimate,
            "nonce": w3.eth.getTransactionCount(w3.toChecksumAddress(account.address))
            }
    elif coin==BTC:
        return {
            PrivateKey.prepare_transaction(account.address, [(recipient, amount, BTC)])
        }
    else:
        return {
            PrivateKeyTestnet.prepare_transaction(account.address, [(recipient, amount, BTC)])
        }



# Create a function called `send_tx` that calls `create_tx`, signs and sends the transaction.
def send_tx(coin,account, recipient, amount):
    # YOUR CODE HERE
    if coin==ETH:
        tx = create_tx(coin, account, recipient,amount)
        signed_tx = account.sign_transaction(tx)
        result = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
        return result.hex()
    elif coin==BTC:
        tx = create_tx(coin, account, recipient,amount)
        signed_tx = account.sign_transaction(tx)
        result = NetworkAPI.broadcast_tx(signed_tx)
        return result.hex()
    else:
        tx = create_tx(coin, account, recipient,amount)
        signed_tx = account.sign_transaction(tx)
        result = NetworkAPI.broadcast_tx_testnet(signed_tx)
        return result.hex()
