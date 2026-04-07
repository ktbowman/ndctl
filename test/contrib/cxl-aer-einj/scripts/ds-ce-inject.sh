#!/bin/bash
bdf="0e:00.0"

aer-inject -s ${bdf} examples/correctable.internal
