from sys import exit
from bitcoin.core.script import *

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                    faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction

left = 648
right = 9444

# x = 648 - y
# x = 9444 + y
# 648 - y = 9444 + y
# 648 - 9444 = 2y
# y = -4398
# x = 5046

######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 2
Q2a_txout_scriptPubKey = [
        OP_2DUP,
        OP_ADD,
        left,
        OP_EQUALVERIFY,
        OP_SUB,
        right,
        OP_EQUAL
    ]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.00009091 # amount of BTC in the output you're sending minus fee
    txid_to_spend = (
        '19ad16298ef5a8f280f5054b4216aec6b8559c6f40dec842e23ae822d9a72332')
    utxo_index = 3 # index of the output you are spending, indices start at 0
    ######################################################################

    response = send_from_P2PKH_transaction(
        amount_to_send, txid_to_spend, utxo_index,
        Q2a_txout_scriptPubKey, my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
