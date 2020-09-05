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

SUBJECTS=$(curl --retry 999 "https://senior-secondary.scsa.wa.edu.au/further-resources/past-atar-course-exams" |
        grep "past-atar-course-exams/" | 
        sed 's|.*past-atar-course-exams/||;s|".*||'
    )

time {

for SUBJECT in $SUBJECTS; do

    FILES=$(curl --retry 999 -Ls "https://senior-secondary.scsa.wa.edu.au/further-resources/past-atar-course-exams/$SUBJECT" | 
        grep -i "tab-link\|\.mp3\|\.mp4\|\.doc\|\.docx\|\.pdf\|\.pptx\|\.wcm\|\.zip" | 
        grep -v 'Guidelines-for-the-delivery-of-Certificate-IV-and-above-VET-qualifications-to-secondary-students.pdf' |
        sed 's|<!--.*||;s|.*tab-link.||;s|.*http|http|;s|".*||;s|</.>|YEAR|;s|[<>]||g'
    )

    message "PROCESS $SUBJECT" INFO

    rm -r "$SUBJECT"
    mkdir -p $SUBJECT

    for file in $FILES; do
        if [ "$(expr match "$file" '.*\(YEAR\)')" ]; then
            year="${file%YEAR}"
            message "   CHANGE YEAR $year" INFO
            out="$SUBJECT/$year"
        else
            message "       CHECK $file" INFO
            curl --retry 999 -Ls -I "$file" | grep 'Content-Type:' | sed 's|Content-Type: |^|;s|text/html.*|error|;s|$|^'$file'|;s|^|'${file//*\//}'|' >> "$out" &
        fi
    done
done

while [ "$(pgrep -a curl | head -n1)" ]; do
    sleep 0.1
done

for SUBJECT in $SUBJECTS; do
    for year in $(ls -1v "$SUBJECT"); do
        sort -t'^' -k1 -u -f $SUBJECT/$year | cut -d'^' -f2- | sed 's|"$||' > $SUBJECT/$year.sort
    done
done

} 2>&1 | tee get.LOG