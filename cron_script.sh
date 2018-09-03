#!/bin/bash

echo "Process starting..."

_now=$(date +"%s_%m_%d_%Y")

_name=$_now

_file_for_start="dumpdata/$_name"

echo "Dumping all folders "

IFS=',' read -r -a array <<< "$FOLDERS";


for folder in "${array[@]}"
do

  echo "Dumping $folder folder..."
  _tarname=$(echo $folder | sed -e 's/\//_/g')
  tar -cvzf "$_file_for_start$_tarname"_bck_`date +%Y%m%d`.tar.gz $folder;

  _file="$_file_for_start$_tarname"_bck_`date +%Y%m%d`.tar.gz

  if [ "$S3_UPLOAD" = "true" ]; then



    echo "S3 upload $folder ($_file)..."

    bucket="$S3_BUCKET"

    host="$S3_HOST"
    link="$S3_PROTOCOL""://""$S3_HOST"

    echo "$link"

    s3_key="$S3_KEY"
    s3_secret="$S3_SECRET"

    resource="/${bucket}/${_file}"
    content_type="application/octet-stream"
    date=`date -R`
    _signature="PUT\n\n${content_type}\n${date}\n${resource}"
    signature=`echo -en ${_signature} | openssl sha1 -hmac ${s3_secret} -binary | base64`
    echo "Eseguo curl"
    echo "Upload di ${_file}"
    curl -v -X PUT -T "${_file}" \
              -H "Host: $host" \
              -H "Date: ${date}" \
              -H "Content-Type: ${content_type}" \
              -H "Authorization: AWS ${s3_key}:${signature}" \
               $link${resource}




  fi

  echo "Removing temp file $_file"

  rm $_file


done


if [ "$CLEAN_DAYS" -gt "0" ]; then
    echo "Cleaning bucket"
    ./cleaner.sh "$S3_BUCKET" "$CLEAN_DAYS days" "dumpdata"

fi
