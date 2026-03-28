#!/bin/bash

if eww active-windows | grep -q music_pop; then
  eww close music_pop
else
  eww open music_pop
fi
