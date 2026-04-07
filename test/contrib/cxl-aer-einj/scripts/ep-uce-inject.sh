#!/bin/bash
bdf="0000:0f:00.0"

aer-inject -s ${bdf} examples/fatal.internal
