#!/bin/bash
bdf="0f:00.0"

aer-inject -s ${bdf} examples/correctable.internal
