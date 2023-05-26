#!/bin/bash

sudo service ntp stop
sudo ntpd -q -g -x -n
