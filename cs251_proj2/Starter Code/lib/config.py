from bitcoin import SelectParams
from bitcoin.base58 import decode
from bitcoin.core import x
from bitcoin.wallet import CBitcoinAddress, CBitcoinSecret, P2PKHBitcoinAddress


SelectParams('testnet')

faucet_address = CBitcoinAddress('mohjSavDdQYHRYXcS3uS6ttaHP8amyvX78')

# For questions 1-3, we are using 'btc-test3' network. For question 4, you will
# set this to be either 'btc-test3' or 'bcy-test'
network_type = 'btc-test3'


######################################################################
# This section is for Questions 1-3
# TODO: Fill this in with your private key.
#
# Create a private key and address pair in Base58 with keygen.py
# Send coins at https://testnet-faucet.mempool.co/

my_private_key = CBitcoinSecret(
    'cTm6xnAMhm6DGkKUkmuBwVM2rVzwS5HprnpmChXg365ZR9qPARNS')
my_corr_address = 'myLgWRxeiXNTDgGmfbMCZp5Q4TjMU7kgy2'
my_trans_hash = '8b59a3810c226f3b9badf419b6a08723ef9d131df50663639ba83d44f47a2a2f'

my_public_key = my_private_key.pub
my_address = P2PKHBitcoinAddress.from_pubkey(my_public_key)
######################################################################


######################################################################
# NOTE: This section is for Question 4
# TODO: Fill this in with address secret key for BTC testnet3
#
# Create address in Base58 with keygen.py
# Send coins at https://testnet-faucet.mempool.co/

# Only to be imported by alice.py
# Alice should have coins!!
alice_secret_key_BTC = CBitcoinSecret(
    'cNYjFbcHLgaGaAp5TP8FDuyh87S5wv9ssGM5W54D2TqA4FiihGJ7')
alice_corr_address = 'mthYNdMD19NjmaETZmYdyVjqHMPY3w3tUU'
alice_trans_hash = 'adb152181f8161a25583dbbf46c71aa7f08e61133aa34656f8043b97587709be'

# Only to be imported by bob.py
bob_secret_key_BTC = CBitcoinSecret(
    'cNpPppX4fpDuYjtU3kETFV23F6NjW897pHwLTtoESMDHgsYAfxd3')
bob_corr_address = 'n4mmAxyY8JNnNGor2Tr7sY4m9GGjLFcv4g'
bob_trans_hash = '8bf0b87d96d1e00c0cec0d7e609000c87fe25f77255f65595871c06e97e9e7e6'

# Can be imported by alice.py or bob.py
alice_public_key_BTC = alice_secret_key_BTC.pub
alice_address_BTC = P2PKHBitcoinAddress.from_pubkey(alice_public_key_BTC)

bob_public_key_BTC = bob_secret_key_BTC.pub
bob_address_BTC = P2PKHBitcoinAddress.from_pubkey(bob_public_key_BTC)
######################################################################


######################################################################
# NOTE: This section is for Question 4
# TODO: Fill this in with address secret key for BCY testnet
#
# Create address in hex with
# curl -X POST https://api.blockcypher.com/v1/bcy/test/addrs?token=YOURTOKEN
# This request will return a private key, public key and address. Make sure to save these.
#
# Send coins with
# curl -d '{"address": "BCY_ADDRESS", "amount": 1000000}' https://api.blockcypher.com/v1/bcy/test/faucet?token=YOURTOKEN
# This request will return a transaction reference. Make sure to save this.

# Only to be imported by alice.py
alice_secret_key_BCY = CBitcoinSecret.from_secret_bytes(
    x('6d2c5eefc35e5990cc1cc6574ef7b1724f98c15c5561f40f2d71e3c2f86d4df1'))
alice_corr_address_BCY = 'C5euDo2yJ7nTscAUTypNA2RMPFuWCDPPFY'
alice_trans_hash_BCY = '25a9e1324d0d1e353cb22d3fca0dfeb9ac118e5bc3d4a5975a313c4bd2c97d32'

# Only to be imported by bob.py
# Bob should have coins!!
bob_secret_key_BCY = CBitcoinSecret.from_secret_bytes(
    x('f4a02f152700bfd3420b4e626bdaa94f129e2f9da6a17ea6e36191c338f1aec1'))
bob_corr_address_BCY = 'C99FrAUyTtgR2mj8493piFSZW9tkocMAMB'
bob_trans_hash_BCY = '2f067efc2e1eee7c3323a991f925c31035f993107b1f958af98f9a0c5f1c1e55'

# Can be imported by alice.py or bob.py
alice_public_key_BCY = alice_secret_key_BCY.pub
alice_address_BCY = P2PKHBitcoinAddress.from_pubkey(alice_public_key_BCY)

bob_public_key_BCY = bob_secret_key_BCY.pub
bob_address_BCY = P2PKHBitcoinAddress.from_pubkey(bob_public_key_BCY)
######################################################################
