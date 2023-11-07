from sys import exit
from bitcoin.core.script import *
from bitcoin.wallet import CBitcoinSecret

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                    faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction


cust1_private_key = CBitcoinSecret(
    'cUroo34oNNX2kRr7WakKsbbxyNkWtiUoyeZEEakQ5kGJpFeUKdbd')
c1_address = 'mq3fGCYmveKuDkrthH5GyStCx3hwpaTD1h'
cust1_public_key = cust1_private_key.pub

cust2_private_key = CBitcoinSecret(
    'cN1svF28ssmTRc1gNuRYAYZJrcf5F2J6y4fuhmMQauXZbW5SFNJZ')
c2_address = 'mvdUaZFpwnVGu9ZBXKZfDusRk7gD6nXCvr'
cust2_public_key = cust2_private_key.pub

cust3_private_key = CBitcoinSecret(
    'cQTv2eheCsE4cxoc5D5WQEEgsnqjN6h5bgBKSKYgZkTKNPoUMCoh')
c3_address = 'mhUXA5s59a65cPGApJLBtweooi35MzDcjc'
cust3_public_key = cust3_private_key.pub


######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 3

# You can assume the role of the bank for the purposes of this problem
# and use my_public_key and my_private_key in lieu of bank_public_key and
# bank_private_key.

# this scriptPK ensures that at least 1 of 3 customers provided a signature and that
# the bank provides a signature as well (both will be included in the scriptSig separated
# by an extra value that gets popped off the stack by OP_CHECKMULTISIGVERIFY)
Q3a_txout_scriptPubKey = [
    1,
    cust1_public_key,
    cust2_public_key,
    cust3_public_key,
    3,
    OP_CHECKMULTISIGVERIFY, # requires that at least 1 customer sig is provided
    my_public_key,
    OP_CHECKSIG # returns 0 if bank sig is not provided
]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.00003091 # amount of BTC in the output you're sending minus fee
    txid_to_spend = (
        '19ad16298ef5a8f280f5054b4216aec6b8559c6f40dec842e23ae822d9a72332')
    utxo_index = 5 # index of the output you are spending, indices start at 0
    ######################################################################

    response = send_from_P2PKH_transaction(amount_to_send, txid_to_spend, 
        utxo_index, Q3a_txout_scriptPubKey, my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
