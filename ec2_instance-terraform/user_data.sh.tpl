#!/bin/bash
HOST_NAME="${name}"
hostnamectl set-hostname --static $HOST_NAME;
reboot;
