#!/bin/bash

my_ip=$(curl -s http://checkip.amazonaws.com)

jq -n --arg my_ip "${my_ip}" '{"my_ip":$my_ip}'
