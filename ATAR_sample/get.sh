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

SUBJECTS=$(curl --retry 999 "https://web.archive.org/web/20161121120807/http://wace1516.scsa.wa.edu.au/syllabus-and-support-materials" | 
        grep '^<h3' | 
        sed 's|</a>|</a>\n|g' | 
        grep -v 'button default lge' | 
        sed 's|.*href=.||;s|.>.*||;$d'
    )

time {

for SUBJECT_ in $SUBJECTS; do
    SUBJECT=${SUBJECT_/*\//}

    FILES=$(curl --retry 999 -Ls "$SUBJECT_" | 
        sed '0,/Examination Materials/d' | 
        grep -i "accordion\|\.mp3\|\.mp4\|\.doc\|\.docx\|\.pdf\|\.pptx\|\.wcm\|\.zip" | 
        sed 's|<!--.*||;s|.*http|http|;s|".*||;s|</.>|YEAR|;s|[<>]||g;/class=/,+50000d'
    )

    message "PROCESS $SUBJECT" INFO

    rm -r "$SUBJECT"
    mkdir -p "$SUBJECT"

    for file in $FILES; do
        message "       CHECK $file" INFO
        curl --retry 999 -Ls 'http://web.archive.org/cdx/search/cdx?url='$file'&output=json' | 
            jq 'if (.[0][0] == null) then
                    "zzzzzzzzzzzzzzzzzzzzzzzzz^error^'$file'"
                else
                    .[] | select(.[4] == "200" and .[3] != "text/html") | "\(.[2] | split("/")[-1])^\(.[3])^web.archive.org/\(.[1])/\(.[2])"
                end' |
            sort -u |
            head -n1 >> "$SUBJECT/sample" &
    done
done

while [ "$(pgrep -a curl | grep 'web.archive.org' | head -n1)" ]; do
    sleep 0.1
done

for SUBJECT in $SUBJECTS; do
    sort -t'^' -k1 -u -f "${SUBJECT/*\//}/sample" | cut -d'^' -f2- | sed 's|"$||' > "${SUBJECT/*\//}/sample.sort"
done
find -size  0 -print -delete

} 2>&1 | tee get.LOG