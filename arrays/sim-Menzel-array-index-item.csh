

cp code/sim-menzel-simulate-index.do temp/sim-menzel-simulate-index-$1.do

nohup stata-mp -b do temp/sim-menzel-simulate-index-$1.do $1
mv sim-menzel-simulate-index-$1.log batch_logs/sim-menzel-simulate-index-$1.log

rm temp/sim-menzel-simulate-index-$1.do

