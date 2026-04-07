#!/bin/bash
bdf="0c:00.0"

aer-inject -s ${bdf} examples/correctable.internal
