#!/bin/bash
for i in *.zip 
do
	name=$(echo "$i" | cut -f 1 -d '.')
	mkdir -p $name
	mv $i $name
	cd $name
	unzip *.zip
	rm *zip
	cd ..  
done
