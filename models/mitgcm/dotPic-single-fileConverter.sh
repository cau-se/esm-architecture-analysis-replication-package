#!/bin/bash

#
# For all .dot and .pic files in the directory passed
# as parameter $1, this script generates image files
# in the format passed as $2..$n by calling the 
# tools dot and pic2plot.
#
# Example: $ dotPic-fileConverter tmp/ svg png ps
#
# @author Andre van Hoorn

function print_usage {
    echo 
    echo "Usage: $(basename "$0") <output-directory> <file-type-1 ... file-type-N>"
    echo 
    echo "Example: $(basename "$0") /tmp/ pdf png ps"
}

if [ ! -f "$1" ]; then
    echo "'$1' is not a file"
    print_usage
    exit 1
fi

if [ -z "$2" ]; then
    echo "Missing file extensions"
    print_usage
    exit 1
fi

FILENAME="$1"
shift

EXTS=$*

f=$FILENAME
BASENAME=$(echo $f | sed -E s/'\.[[:alnum:]]+$'//g); 
for ext in ${EXTS}; do 
    dot -T ${ext} "${f}" > "${BASENAME}".${ext} ; 
    if (echo "${ext}" | grep -q pdf); then
	(pdfcrop "${BASENAME}.pdf" > /dev/null) \
	    && rm "${BASENAME}.pdf" \
	    && mv "${BASENAME}-crop.pdf" "${BASENAME}".pdf
    fi
done

# end
