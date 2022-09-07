#!/bin/bash
# Download https://download.geonames.org/export/dump/cities1000.zip and unzip it
# Download https://download.geonames.org/export/dump/admin1CodesASCII.txt

DATA=data
rm -f $DATA/*
IFS='|'
while read -r geonameid name asciiname alternatenames latitude longitude featureclass featurecode countrycode cc2 admin1code admin2code admin3code admin4code population elevation dem timezone
do
  subcountry=`grep "^$countrycode.$admin1code\t"  admin1CodesASCII.txt | cut -f2`
  res=$DATA/$countrycode.json
  if [ ! -f $res ]; then
    echo "[" > $res
  fi

  echo -e "  {
    \"country\": \"$countrycode\",
    \"geonameid\": $geonameid,
    \"name\": \"$asciiname\",
    \"alternatenames\": \"$alternatenames\",
    \"subcountry\": \"$subcountry\"
  }," >> $res
done < <(cat cities1000.txt | tr '\t' '|' | sed 's/"//g' | sed 's/\\/\\\\\\/g')

for f in $DATA/*json; do
  sed -i '' '$d' $f
  echo "  }
]" >> $f
done

# jq version too slow
# IFS='|'
# while read -r geonameid name asciiname alternatenames latitude longitude featureclass featurecode countrycode cc2 admin1code admin2code admin3code admin4code population elevation dem timezone
# do
#   if [ ! -f data/$countrycode.json ]; then
#     echo "[]" > data/$countrycode.json
#   fi
#   subcountry=`grep "^$countrycode.$admin1code\t"  admin1CodesASCII.txt| cut -f2`
#   c="{\"country\": \"$countrycode\", \"geonameid\": $geonameid, \"name\": \"$asciiname\", \"alternatenames\": \"$alternatenames\", \"subcountry\": \"$subcountry\"},"
#   let count=$count+1
#   cat <<< $(jq ". += [${c%?}]" data/$countrycode.json) > data/$countrycode.json
# done < <(cat cities1000.txt | tr '\t' '|' | sed 's/"//g' | sed 's/\\/\\\\/g')
