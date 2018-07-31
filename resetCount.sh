#!/bin/bash

filename=$1

lunreset() {

echo ""
echo "Please allow some time to scan the log..."
echo ""


#
# create files:
#     1) collect loading VProbe script in file1
#     2) collect Script unloaded from vmkernel
#
cat $filename | grep -iE "Attempt to issue lun reset" > 1.txt
cat $filename | grep -iE "Executed out-of-band lun reset" > 2.txt

#
#  Populate a list of lun and target resets and put it in lun/target-count.txt
#
echo "Collecting a list of lun and target resets from vmkernel..."
paste 1.txt 2.txt | (
let j=1
while read -r rowFromFile1 rowFromFile2 ; do
echo "$j: ${rowFromFile1}, ${rowFromFile2}" >> lunreset-count.txt
let j++
done
)


#
# get lun/target reset count
#
echo "Get Lun/Target reset count..."
echo "" >> lunreset-count.txt
echo "" >> lunreset-count.txt
echo -e "Attempt to issue lun reset:" >> lunreset-count.txt
cat $filename | grep -c -iE "Attempt to issue lun reset" >> lunreset-count.txt
echo "" >> lunreset-count.txt
echo -e "Executed out-of-band lun reset:" >> lunreset-count.txt
cat $filename | grep -c -iE "Executed out-of-band lun reset" >> lunreset-count.txt
echo "" >> lunreset-count.txt


#
# search vmkernel to see if there are any lun/target resets issued that is less than 1 seconds.
#
echo "Searching the list to see if there are any lun reset that is more than 1 seconds..."
paste 1.txt 2.txt | (
let i=1
let k=0   # a counter keep track on lunreset that is more than 1 sec


echo "" >> lunreset-count.txt
echo "" >> lunreset-count.txt
echo "=Lun reset took more than 1 second=" >> lunreset-count.txt
echo "" >> lunreset-count.txt

while read -r rowFromFile1 rowFromFile2 ; do
#echo "$i: ${rowFromFile1}, ${rowFromFile2}"

#
# read each line then Convert Date/Time into EPOCH for both files
#
dateTime1="$(echo ${rowFromFile1} | awk '{print $1}' | sed s/.$//)"
EPOC1="$(date +%s -d"$dateTime1")"

dateTime2="$(echo ${rowFromFile2} | awk '{print $21}' | sed s/.$//)"
EPOC2="$(date +%s -d"$dateTime2")"

#
#  evaulate the time difference
#  if reset took more than 2 seconds, return that output
#
timeValue="$(expr $EPOC2 - $EPOC1)"
if [[ $timeValue -gt 1 ]]; then
   echo "$i: ${rowFromFile1}, ${rowFromFile2}" >> lunreset-count.txt
   echo "" >> lunreset-count.txt
   let k++
fi

let i++
done

rm -f 1.txt
rm -f 2.txt
echo "Scan finished..."
echo ""
echo "      lunreset-count.txt has been created"
echo ""
)
}


targetreset() {

echo ""
echo "Please allow some time to scan the log..."
echo ""


#
# create files:
#     1) collect loading VProbe script in file1
#     2) collect Script unloaded from vmkernel
#
cat $filename | grep -iE "Attempt to issue target reset" > 3.txt
cat $filename | grep -iE "Executed out-of-band target reset" > 4.txt


#
#  Populate a list of lun and target resets and put it in lun/target-count.txt
#
paste 3.txt 4.txt | (
let k=1
while read -r rowFromFile3 rowFromFile4 ; do
echo "$k: ${rowFromFile3}, ${rowFromFile4}" >> targetreset-count.txt
let k++
done
)



#
# get target reset count
#


echo "" >> targetreset-count.txt
echo "" >> targetreset-count.txt
echo -e "Attempt to issue target reset:" >> targetreset-count.txt
cat $filename | grep -c -iE "Attempt to issue target reset" >> targetreset-count.txt
echo "" >> targetreset-count.txt
echo -e "Executed out-of-band target reset:" >> targetreset-count.txt
cat $filename | grep -c -iE "Executed out-of-band target reset" >> targetreset-count.txt
echo "" >> targetreset-count.txt



#
# search vmkernel to see if there are any lun/target resets issued that is less than 1 seconds.
#
echo "Searching the list to see if there are any lun reset that is more than 1 seconds..."

let l=1
let m=0   # a counter keep track on targetreset that is greater than 1 sec


echo "" >> targetreset-count.txt
echo "" >> targetreset-count.txt
echo "=Target reset took more than 1 second=" >> targetreset-count.txt
echo "" >> targetreset-count.txt

paste 3.txt 4.txt | while read rowFromFile3 rowFromFile4
do
# debug the line
#echo "$l: ${rowFromFile3}, ${rowFromFile4}"
#
# read each line then Convert Date/Time into EPOCH for both files
#
dateTime3="$(echo ${rowFromFile3} | awk '{print $1}' | sed s/.$//)"    # read from left to right
EPOC3="$(date +%s -d"$dateTime3")"

dateTime4="$(echo ${rowFromFile4} | awk  '{print $(NF-8) }' | sed s/.$//)"     # read from right to left
EPOC4="$(date +%s -d"$dateTime4")"

#
#  evaulate the time difference
#  if reset took more than 1 seconds, return that output
#
timeValue=$(expr $EPOC4 - $EPOC3)

if [[ $timeValue -gt 1 ]]; then
   echo "$l: ${rowFromFile3}, ${rowFromFile4}" >> targetreset-count.txt
   echo "" >> targetreset-count.txt
   let m++
fi

let l++
done

rm -f 3.txt
rm -f 4.txt
echo "Scan finished..."
echo ""
echo "      targetreset-count.txt has been created"
echo ""

}




if [[ -n "$filename" ]]; then
  lunreset "$filename"
  targetreset "$filename"

else
  echo ""
  echo ""
  echo "	Usage: resetCount.sh <filename>"
  echo ""
  echo "               example: sh resetCount.sh vmkernel.consolidated.log"
  echo ""
  echo "           Note:  if there are multiple vmkernel logs, such as vmkernel.0.gz,vmkernel.1.gz,..etc "
  echo "                  ensure to consolidate the logs in a sorted order. "
  echo ""
fi
