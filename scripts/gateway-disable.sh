#!/bin/bash
# This script disables the gateway functionality by disabling the PF firewall.
# It ensures all gateway-related network changes are reverted cleanly.

sudo pfctl -d
