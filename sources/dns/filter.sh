#!/bin/sh
grep price_g | head -1 | awk -F '\\>' '{print $2}' | awk -F '\\&nbsp' '{print $1}' | sed 's/\ //g'
