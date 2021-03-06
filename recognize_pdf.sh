#!/bin/bash
RESOLUTION=300
LANG="deu"

if [[ -z "$1" ]]; then
    exit
fi
  
  
SOURCEFILE="$1"
OUTPUTFILE="${SOURCEFILE%.pdf}"
PAGES=$(mdls -name kMDItemNumberOfPages -raw "$SOURCEFILE")

FINALNAME="$OUTPUTFILE.pdf"
TEMPDIR="temp_page_dir"
OUTPUTDIR="$TEMPDIR/OCR"

mkdir -p "$TEMPDIR"
mkdir -p "$OUTPUTDIR"

for i in $(seq 1 $PAGES); do
    echo "Converting page $i/$PAGES to image."
    convert -density "$RESOLUTION"x"$RESOLUTION" -set units PixelsPerInch -depth 8 "$SOURCEFILE"\[$(($i - 1 ))\] $TEMPDIR/page$i.png
    echo "Running OCR for languages $LANG."
    tesseract "$TEMPDIR/page"$i.png "$OUTPUTDIR"/"$OUTPUTFILE"$i -l "$LANG" pdf
    
    echo "---"
done

echo "Combining searchable PDFs into one file..."
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$OUTPUTFILE ocr.pdf" "$OUTPUTDIR/$OUTPUTFILE"*.pdf && rm -r "$OUTPUTDIR" && rm -r "$TEMPDIR"
echo "All done. Output file name is: $OUTPUTFILE ocr.pdf"
# echo "ALERT:Conversion completed|Output file name is: $OUTPUTFILE ocr.pdf\n" # Displays alert in Platypus app runtime