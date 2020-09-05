
OUTFILE="root.json"

echo '[{
    "text":"ROOT",
    "state":{"opened":true},
    "children":[' > "$OUTFILE"
for dir in $(ls -1vd */); do
    echo '{ "text" : "'${dir%?}'", "children": [' >> "$OUTFILE"
    cd "$dir"
    for year in $(ls -1v | grep '^[0-9]*$'); do
        echo '{"text":"'$year'","state":{"opened":true},"children":[' >> "../$OUTFILE"
        while read; do
            # echo "${REPLY//*,/}"
            # echo "${REPLY//*\//}"
            case ${REPLY//,*/} in
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
            # echo "$type"
            echo '{"text":"'"${REPLY//*\//}"'","type":"'$type'","url":"'"${REPLY//*^/}"'"},' >> "../$OUTFILE"
        done <<< "$(cat "$year.sort")"
        truncate -s-2 "../$OUTFILE"
        echo "]}," >> "../$OUTFILE"
        echo "$dir $year"
    done
    cd ..
    truncate -s-2 "$OUTFILE"
    echo ']},' >> "$OUTFILE"
done
truncate -s-2 "$OUTFILE"
echo "]}]" >> "$OUTFILE"