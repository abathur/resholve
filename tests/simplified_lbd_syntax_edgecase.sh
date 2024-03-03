#!/bin/bash
D4=4
D1=2

# this is the form osh suggests we adapt to
if [ $[ D1 * 3600 ] -lt $D4 ]
then
  echo "FOUND"
fi

# this form produces the suggestive error
if [ $[ $D1 * 3600 ] -lt $D4 ]
then
  echo "FOUND"
fi
