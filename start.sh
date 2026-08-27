#!/bin/sh

   killall conky
   cd "$HOME/.conky/conky-nextgen"
   conky -c "$HOME/.conky/conky-nextgen/clock_cal.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/cpu.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/disk.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/info.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/mem_swap.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/network.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/top.conf" &
   
   conky -c "$HOME/.conky/conky-nextgen/weather.conf" &
   
   exit 0

