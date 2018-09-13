#!/usr/bin/env bash

touch baseline.txt

for f in TEST*
do
  ruby $f | tee -a baseline.txt
done
