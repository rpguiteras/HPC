

set DONAME="sim-Menzel-bsbc-simulate-index"

cp code/$DONAME.do temp/$DONAME-$1.do

stata-mp -b do temp/$DONAME-$1.do $1

mv $DONAME-$1.log batch_logs/$DONAME-$1.log

rm temp/$DONAME-$1.do

