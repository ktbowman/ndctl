#!/bin/bash
bdf="0d:00.0"

aer-inject -s ${bdf} examples/correctable.internal
