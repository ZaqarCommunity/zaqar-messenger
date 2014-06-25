#!/bin/sh
# Clean, compile and run Hello World
rm helloworld.js
coffee --compile helloworld.coffee
nodejs helloworld.js
