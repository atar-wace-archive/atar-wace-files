
OUTFILE="root.json"

cd "./ALL"
# --------------------------------------------------------------------
# IMPORTANT ! SET THIS CD TO THE DIRECTORY CONTAINING ALL SORTED LISTS
# --------------------------------------------------------------------

doc() {
    while read; do
        if [ ! "$REPLY" ]; then
            REPLY="error^http://error/no_file_in_source"
        fi
        case ${REPLY//^*/} in
            application/pdf)
                type="pdf"
                ;;
            audio/mpeg)
                type="mp3"
                ;;
            video/mp4)
                type="mp4"
                ;;
            application/msword|application/vnd.openxmlformats-officedocument.wordprocessingml.document)
                type="doc"
                ;;
            error)
                type="error"
                ;;
            *)
                type="default"
                ;;
        esac
        URL="${REPLY//*^/}"
        if [ "${URL:0:4}" != 'http' ]; then
            URL="http://$URL"
        fi #patch to reverse the removal of the protocol (which was removed earlier in the reformatting process I think)
        echo '{ "text" : "'"${REPLY//*\//}"'", "type" : "'$type'", "url" : "'"${URL}"'" },' >> "$OUTFILE"
    done <<< "$(cat "$SOURCE")"
}
time {
echo '[{
    "text" : "ROOT",
    "state" : { "opened" : true },
    "children" : [' > "$OUTFILE"
for dir in $(ls -1vd */); do
    echo '{ "text" : "'${dir%?}'", "children": [' >> "$OUTFILE"
    for year in $(ls -1v "$dir"); do
        case ${year//.sort/} in
            2007-2008_wace_draft)
                echo '{ "text" : "'${year//.sort/}'", "state" : { "opened" : false }, "children": [' >> "$OUTFILE"
                while IFS= read -r file; do
                    echo '{ "text" : "'${file//.sort/}'", "state" : { "opened" : true }, "children": [' >> "$OUTFILE"
                    SOURCE="$dir/2007-2008_wace_draft.sort/$file"
                    doc
                    truncate -s-2 "$OUTFILE"
                    echo "]}," >> "$OUTFILE"
                done <<< "$(ls -1v "$dir/2007-2008_wace_draft.sort" | grep 'sort')"
                ;;
            2009|2009_samples|2010|2011|2012|2013|2014|2015|2006_wace_draft)
                echo '{ "text" : "'${year//.sort/}'", "state" : { "opened" : false }, "children": [' >> "$OUTFILE"
                SOURCE="$dir/$year"
                doc
                ;;
            *)
                echo '{ "text" : "'${year//.sort/}'", "state" : { "opened" : true }, "children": [' >> "$OUTFILE"
                SOURCE="$dir/$year"
                doc
                ;;
        esac
        truncate -s-2 "$OUTFILE"
        echo "]}," >> "$OUTFILE"
    done
    echo "$dir"

    truncate -s-2 "$OUTFILE"
    echo ']},' >> "$OUTFILE"
done
truncate -s-2 "$OUTFILE"
echo "]}]" >> "$OUTFILE"
}

# cp root.json ../atar-wace-archive/