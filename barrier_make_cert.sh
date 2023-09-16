#!/bin/bash
cd ~/.local/share/barrier/SSL
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out Barrier.cert
openssl req -key Barrier.cert -x509 -new -out Barrier.pem
cat Barrier.cert >> Barrier.pem 
