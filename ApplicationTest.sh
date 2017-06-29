x=1
while true;
do
clear
echo ""
echo "Request: $x"
echo "-------------"
echo ""
echo ""
curl http://kube001:30000
echo ""
echo ""
echo ""
x=$(( $x + 1 ))
sleep 2

done
