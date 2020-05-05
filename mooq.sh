#!/bin/bash

# Mooquita Linux Challenge - beginner
# made by jvm-mx 05/may/2020.

# Create a temporal workdir, exit in case of failure:
WORKDIR=$(mktemp -d /tmp/challenge.XXXXXXXX) 
cd "$WORKDIR" || exit

# To create the series of random numbers and strings: read from standard input (/dev/urandom), select only letters and digits [:alnum:], wrap each line to the length selected via shuf command, and read 1MiB of data.
lineLength="$(shuf -i 1-15 -n 1)"
inputData=$(</dev/urandom tr -cd "[:alnum:]" | fold -w "$lineLength" | head -c 1MiB)

# Decided this method over others because: 
# It is faster to obtain the full random stream from /dev/urandom, limiting the output to letters and digits via tr command.
# Other approaches I tried:
# Selecting x bytes, with x from 1 to 15 and writing them to a file in a do loop: 
#do
	#newline=$(</dev/urandom tr -cd [:alnum:] | fold -w $lineLength | head -1)
	#printf "Line is $newline"
	#myfile+="${newline}"$'\n'
	#printf "Myfile size is ${#myfile}\n"
#done
# Another approach: select 1MiB of data from /dev/urandom, create a file of n lines, to indicate how many characters should be taken each time and write them to a file, until 1MiB is reached.
# To control the filesize, my choice was to print via head the desired amount of bytes, other options I tried were wc and stat command:
#stat --format '%s' foo.sh 
#6643
#wc -c foo.sh 
#6643 foo.sh

# To sort the data using native byte values, avoiding override of locale, simply put LC_ALL=C before sort command, if we don't specify this, the sort will be performed according the current locale sequence:
sortedData=$(LC_ALL=C sort <<< "$inputData")

# How many lines does the sorteData variable has?
totalLines=$(wc -l  <<< "$sortedData")

# Start reading, line by line, the sorteData variable
removedLines=0
currentLine=1
while read -r line
do
	if [[ "$line" =~ ^[Aa] ]]; then
		#to count how many lines are removed
		removedLines=$((removedLines + 1))
	else
		# if line does not starts with A or a, write it to another variable. 
		if [[ currentLine -eq totalLines ]]; then
		# This if prevents adding newline when the last line is reached.
			finalData+="$line"
		else
			finalData+="$line\n"
		fi
	fi
currentLine=$((currentLine + 1))
done <<< "$sortedData"

# Finally, save the random character file (inputData) and the sorted-random and cleaned file (finalData)
inputDataFile=$(mktemp inputData.XXXXXXXX)
finalDataFile=$(mktemp finalData.XXXXXXXX)
printf "%b" "$inputData" > "$inputDataFile"
printf "%b" "$finalData" > "$finalDataFile"
printf "Initial file has %d lines\n" "$totalLines"
printf "The process removed %d lines\n" "$removedLines"
printf "Final file has %d lines\n" "$((totalLines - removedLines))"