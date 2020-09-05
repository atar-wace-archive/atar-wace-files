
message() {
    PAD=$(bc <<< "$(tput cols)-$(printf '%s' "$1" | tail -n1 | sed 's/\x1b\[[0-9;]*m//g' | wc -c)-16")
    printf '%s' "$1"
    printf ' %.0s' $(seq 1 ${PAD})
    case "$2" in
        OK)
            printf '\e[1;34m[   \e[1;32mOK\e[1;34m   ]\e[0m\n'
            ;;
        INFO)
            printf '\e[1;34m[  \e[1;36mINFO\e[1;34m  ]\e[0m\n'
            ;;
        FAILED)
            printf '\e[1;34m[ \e[1;31mFAILED\e[1;34m ]\e[0m\n'
            ;;
        *)
            printf '\e[1;34m[        ]\e[0m\n'
            ;;
    esac
}

SUBJECTS=$(curl --retry 999 "https://web.archive.org/web/20160406224308/http://www.scsa.wa.edu.au/internet/Publications/Past_WACE_Examinations" | #Later version has music included.
        grep 'Past_WACE_Examinations/' |
        sed 's|">.*||;s|.*/||'
    )

time {

for SUBJECT in $SUBJECTS; do

    message "PROCESS $SUBJECT" INFO

    rm -r "$SUBJECT"
    mkdir -p $SUBJECT

    for date in 20160514162549 20130331034754; do
    
        FILES=$(curl --retry 999 -Ls "web.archive.org/web/$date/http://www.scsa.wa.edu.au/internet/Publications/Past_WACE_Examinations/$SUBJECT" |
            grep 'href=\|<th ' |
            grep -i "<th\|\.mp3\|\.mp4\|\.doc\|\.docx\|\.pdf\|\.pptx\|\.wcm\|\.zip" |
            perl -pe 's|.*?scsa|scsa|;s|">[[<].*||;s|.*?>||;s| WACE.*th>|YEAR|'
        )
        # c=0
        for file in $FILES; do
            if [ "$(expr match "$file" '.*\(YEAR\)')" ]; then
                # while [ "$(pgrep -a curl | grep 'web.archive.org' | head -n1)" ]; do
                #     sleep 0.1
                # done
                year="${file%YEAR}"
                message "   CHANGE YEAR $year" INFO
                out="$SUBJECT/$year"
            else
                #example of one that does not work: http://newwace.curriculum.wa.edu.au/docs/pd1510/188795_4.doc
                # ((c++))
                message "       CHECK $file" INFO
                curl --retry 999 -Ls 'http://web.archive.org/cdx/search/cdx?url='$file'&output=json' | 
                    jq 'if (.[0][0] == null) then
                            "zzzzzzzzzzzzzzzzzzzzzzzzz^error^'$file'"
                        else
                            .[] | select(.[4] == "200" and .[3] != "text/html") | "\(.[2] | split("/")[-1])^\(.[3])^web.archive.org/\(.[1])/\(.[2])"
                        end' |
                    sort -u |
                    head -n1 >> "$out" &
            fi
        done
    done
    while [ "$(pgrep -a curl | grep 'web.archive.org' | head -n1)" ]; do
        sleep 0.1
    done
done

while [ "$(pgrep -a curl | grep 'web.archive.org' | head -n1)" ]; do
    sleep 0.1
done

for SUBJECT in $SUBJECTS; do
    for year in $(ls -1v "$SUBJECT"); do
        sort -t'^' -k1 -u -f $SUBJECT/$year | cut -d'^' -f2- | sed 's|"$||' > $SUBJECT/$year.sort
    done
done

} 2>&1 | tee get.LOG