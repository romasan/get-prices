grep price_g -A2 | tail -1 | sed 's/\ //g' | awk '{print $1}'
