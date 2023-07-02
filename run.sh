#!/usr/bin/env bash

# This script can be used to simplify the execution of tests. 
# You can use the level folder name, the challenge number, or
# the first four letters of the name.


case $1 in

  free2call | 1 | unst)
    forge test --match-contract Free2Call
    ;;

  twice-as-nice | 2 | naiv)
    forge test --match-contract TwiceAsNice
    ;;

  stir-it-up | 3 | trus)
    forge test --match-contract StirItUp
    ;;

  honeypot | 4 | side)
    forge test --match-contract Honeypot
    ;;

  *)
    echo "Invalid input use either the challenge number, the name of the contract folder, or the first 4 letter of the name (lowercase)"
    ;;
esac

