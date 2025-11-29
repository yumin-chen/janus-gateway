#!/bin/bash
sudo sysctl -w net.inet.ip.forwarding=1
sudo pfctl -f ./config/pf.conf
sudo pfctl -e
