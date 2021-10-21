CONFIG_FILE=config.ini
NODES_FILE=nodes.tmp
TEMP_FILE=temp.tmp
SEARCH_FILE=search.tmp
EXCLUDE_SEARCH_FILE=exclude_search.tmp
OUTPUT_FILE=output_parent_child.out

>$TEMP_FILE
>$OUTPUT_FILE
>$EXCLUDE_SEARCH_FILE

trap _exit_clean EXIT

_find_parent () {
	PARENT_FOUND=0
	
	while [ $NODES -ge 2 ]
	do
		SEARCHP=""
		for ((LEVEL=2; LEVEL<=$NODES; LEVEL++))
		do
			CUTFS=$(echo $FS | cut -d_ -f$LEVEL)
			SEARCHP="${SEARCHP}_${CUTFS}"
		done
		# echo $SEARCHP
		((NODES-=1))
		
		egrep "^$SEARCHP$" $SEARCH_FILE &>/dev/null
		if [ $? -eq 0 ]
		then
			# echo "PARENT: $SEARCHP"
			PARENT_FOUND=1
			break
		fi
	done
	
	return $PARENT_FOUND
}

_sort () {
	cat $CONFIG_FILE > $NODES_FILE
	sed -i "s/\//_/g" $NODES_FILE
	
	for ENTRY in $(cat $NODES_FILE)
	do
		LEVELS=$(echo $ENTRY | awk -F"_" '{print NF-1}')
		echo $LEVELS $ENTRY >> $TEMP_FILE
	done
	cat $TEMP_FILE | sort -r -n -k1 > $NODES_FILE
	cat $TEMP_FILE | sort -r -n -k1 | awk '{print $2}' > $SEARCH_FILE

	TOTAL_FS=$(cat $NODES_FILE | wc -l)
	for ((NUM=1; NUM<=$TOTAL_FS; NUM++))
	do
		FS=$(cat $NODES_FILE | head -$NUM | tail -1)
		NODES=$(echo $FS | awk '{print $1}')
		FS=$(echo $FS | awk '{print $2}')
		
		# echo -e "FS: $FS | NODES: $NODES"
		
		egrep "^$FS$" $EXCLUDE_SEARCH_FILE &>/dev/null
		if [ $? -ne 0 ]
		then
			FS_ENTRY="$FS"
			while true
			do
				_find_parent
				if [ $? -eq 0 ]
				then
					echo $FS_ENTRY >> $OUTPUT_FILE
					break
				fi
				echo $FS >> $EXCLUDE_SEARCH_FILE
				FS_ENTRY="${SEARCHP}:${FS_ENTRY}"
				FS=$SEARCHP
			done
		fi
	done
	
	sed -i "s/_/\//g" $OUTPUT_FILE
	cat $OUTPUT_FILE > $TEMP_FILE
	>$OUTPUT_FILE
	for ENTRY in $(cat $TEMP_FILE)
	do
		LEVELS=$(echo $ENTRY | awk -F: '{print NF}')
		echo "$LEVELS $ENTRY" >> $OUTPUT_FILE
	done
}

_exit_clean () {
rm -rf $NODES_FILE $TEMP_FILE $SEARCH_FILE $EXCLUDE_SEARCH_FILE
}
_sort

