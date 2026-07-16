#!/bin/bash
IDX="$1"
DONAME="sim-Menzel-bsbc-simulate-index"

cp "$DONAME.do" "temp/$DONAME-$IDX.do"
stata-mp -b do "temp/$DONAME-$IDX.do" "$IDX"
mv "$DONAME-$IDX.log" "batch_logs/$DONAME-$IDX.log"
rm "temp/$DONAME-$IDX.do"
