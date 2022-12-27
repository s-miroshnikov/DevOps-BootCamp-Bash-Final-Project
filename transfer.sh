#!/bin/bash

# This script provides functionality to upload files from terminal to https://transfer.sh as well as download from  https://transfer.sh

currentVersion="0.0.1"
# we will use some colors for output
RED='\e[1;31m'
GREEN='\e[1;32m'
NC='\033[0m'

# this is help function to show script usage and some examples
help() {
  echo -e "Description: Bash tool to transfer files from the command line.
  Usage:
  ${GREEN}-d${NC}  download file from the https://transfer.sh
  ${GREEN}-h${NC}  Show the help with examples 
  ${GREEN}-v${NC}  Get the tool version
  Examples:
  ./transfer.sh -d /dir transferID myfile.txt
  download file with ID 'transferID' and with name myfile.txt and save it into /dir directory 
  ./transfer.sh filetoupload.pdf
  upload the filetoupload.pdf file to  https://transfer.sh
  ./transfer.sh file1 file2 file3 
  upload multiple files: file1, file2 and file3 to  https://transfer.sh
 "
   exit 0
}

# this small function shows version of script
version_check() {
  echo "${currentVersion}"
  exit 0
}

# this function will return upload result with url of uploaded file
print_upload_response() {
  Uploadresponse=$(curl --progress-bar --upload-file "${tempFileName}" "https://transfer.sh/${tempFileName}") || { echo -e "${RED}Failure!${NC}"; return 1;}
  echo "Transfer File URL: ${Uploadresponse}"
}

# with this function we check if the each of target files exists and are files and then we call response function
single_upload() {
  for fileToUpload in "$@"; do
    filePath=$( echo "${fileToUpload//"~"/"$HOME"}")
    if [ ! -f "${filePath}" ] ;then  
      echo "Error: invalid file path"
      return 1
    fi
    tempFileName=$(echo "${fileToUpload}" | sed "s/.*\///")
    echo "Uploading ${tempFileName}"
    print_upload_response
  done
  exit 0
}

# this function will return result of downloading 
print_download_response() {
  echo "Downloading ${DownloadfileName}"
  Downloadresponse=$(curl --progress-bar https://transfer.sh/"${DownloadtransferID}/${DownloadfileName}" -o "${DownloadfileDir}"/"${DownloadfileName}") || { echo -e "${RED}Failure!${NC}"; return 1;}
  echo "${Downloadresponse}"
  echo "Success!"
}

# with this function we check if the target directory exists, save https://transfer.sh ID and file name and then we call response function  
single_download() {
  DownloadfileDir=$(echo "$2" | sed s:"~":"$HOME":g)
  if [ ! -e "${DownloadfileDir}" ] ;then  
    echo "Error: invalid path"
    return 1
  fi
  DownloadtransferID="$3"
  DownloadfileName="$4"
  print_download_response
  exit 0
}

# we have only few flags, with calling script without any flag it will upload files to https://transfer.sh
while getopts "dvh" opt; do
  case "$opt" in
    
    d) single_download "$@" ;;
    h) help ;;
    v) version_check ;;
    *) echo "Please, use proper options, for example -h for help."
    exit 1 ;;
  esac
done

single_upload "$@" || exit 1
