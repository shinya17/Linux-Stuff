#!/bin/bash

timedatectl set-ntp false&&timedatectl set-ntp true

systemctl --user restart pipewire.service pipewire-pulse.service wireplumber.service 
