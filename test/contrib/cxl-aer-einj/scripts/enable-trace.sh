#!/bin/bash

echo 1 >  /sys/kernel/debug/tracing/events/cxl/enable
echo 1 > /sys/kernel/debug/tracing/events/cxl/cxl_aer_correctable_error/enable
echo 1 > /sys/kernel/debug/tracing/events/cxl/cxl_aer_uncorrectable_error/enable
