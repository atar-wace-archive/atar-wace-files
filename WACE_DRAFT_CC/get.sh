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

DATE=20080720054337 #ORIGINALLY USED 20080210162935

SUBJECTS=$(curl -Ls "https://web.archive.org/web/20080720054337/http://www.curriculum.wa.edu.au:80/internet/Senior_Secondary/Courses" | 
        grep /Courses/ | 
        sed 's|.*Courses/||;s|".*||'
    )

time {

for SUBJECT in $SUBJECTS; do
    # SUBJECT=Accounting_Finance
    message "PROCESS $SUBJECT" INFO

    rm -r "$SUBJECT"
    mkdir -p $SUBJECT
    time {
    for DATE in 20080210162935 20080720054337; do #Some links are strangely uncommon (design stage ii exam for example.)
        while read; do
            if [ "$REPLY" -a "$(sed 's|\**||' <<< "$REPLY")" ]; then
                if [ ! "$(grep http <<< "$REPLY")" ]; then
                    # while [ "$(pgrep -a curl | grep 'web.archive.org' | head -n1)" ]; do
                    #     sleep 0.1
                    # done
                    year="${REPLY%YEAR}"
                    year=$(sed 's|[/]|_|g;s/[|]/\|/g' <<< "$year")
                    message "   CHANGE DIR $year" INFO
                    out="$SUBJECT/$year"
                    out="${out//:/}"
                    touch "$out"
                else
                    #example of one that does not work: http://newwace.curriculum.wa.edu.au/docs/pd1510/188795_4.doc
                    message "       CHECK $REPLY" INFO &
                    for i in 1 2 3 4; do #this quadruples our stress but wayback machine is being very unreliable and returning empty [] ones when the X-App-Server is wwwb-app15, so this was the easiest solution
                    #this also makes it very long - from ~19 mins to over 50 mins. I suspect the reason for the unreliability is that the servers aren't synced for newwace.curriculum.wa.edu.au - curriculum.wa.edu.au and scsa.wa.edu.au and wace1516 works reliabily between all wayback machine api servers
                    curl --retry 999 -Ls 'http://web.archive.org/cdx/search/cdx?url='$REPLY'&output=json' | 
                        jq 'if (.[0][0] == null) then
                                "'${REPLY//*\//}'^ZZZZZZZZZZZZZZZZZerrorZZZZZZZZZZZZZZZZZ^'$REPLY'"
                            else
                                .[] | select(.[4] == "200" and .[3] != "text/html") | "\(.[2] | split("/")[-1])^\(.[3])^web.archive.org/\(.[1])/\(.[2])"
                            end' |
                        # jq 'if ('$c' == 2 or '$c' == 5) then
                        #         "zzzzzzzzzzzzzzzzzzzzzzzzz^error^'$REPLY'"
                        #     else
                        #         .[] | select(.[4] == "200" and .[3] != "text/html") | "\(.[2] | split("/")[-1])^\(.[3])^web.archive.org/\(.[1])/\(.[2])"
                        #     end' |
                        sort -u |
                        head -n1 >> "$out" &
                    done
                    while [ "$(pgrep -a curl | grep 'web.archive.org' | wc -l)" -gt 2 ]; do #May need to change this threshold if jq starts throwing out errors.
                        sleep 0.1
                    done
                fi
            fi
        done <<< $(curl --retry 999 -Ls "https://web.archive.org/web/$DATE/http://www.curriculum.wa.edu.au:80/internet/Senior_Secondary/Courses/$SUBJECT" |
            sed '0,/>Exams/d' | 
            grep '<td\|curriculum\|</table\|<p \|<font color="#9' | 
            sed '/<\/table>/,+5000 d' | 
            perl -pe 's|.*?//||;s|.*?http|http|;s|<.*?>||g;s|">.*||;s|^ *||;s|&#160;||g' | 
            perl -pe 's/\x{c2}\x{a0}//g;s/[*][*]//g' | 
            grep -v '.*_icon.jpg' |
            tac
        )
        
        # COMMENT WRITTEN ON WEBSITE FOR CLARITY; DO NOT CONTACT ADDRESS! "** These documents are awaiting copyright clearance for electronic communication. Print versions are available by contacting pdenquiry@curriculum.wa.edu.au."
    done
    }

    while [ "$(pgrep -a curl | grep 'web.archive.org' | head -n1)" ]; do
        sleep 0.1
    done

    while read; do
        sort -t'^' -k2 -f "$SUBJECT/$REPLY" > "$SUBJECT/$REPLY.sort"
        c=1
        while [ $c -le $(wc -l < "$SUBJECT/$REPLY.sort") ]; do
            test="$(awk 'NR=='$c "$SUBJECT/$REPLY.sort" | sed 's|.*/||')"
            if [ "$(grep "$test" "$SUBJECT/$REPLY.sort")" ]; then
                awk '!/'${test}'$/ || !f++' "$SUBJECT/$REPLY.sort" > "$SUBJECT/$REPLY.tmp"
                mv "$SUBJECT/$REPLY.tmp" "$SUBJECT/$REPLY.sort"
            fi
            ((c++))
        done
        sort -t'^' -k1 -f "$SUBJECT/$REPLY.sort" | cut -d'^' -f2- | sed 's|"$||;s|ZZZZZZZZZZZZZZZZZerrorZZZZZZZZZZZZZZZZZ|error|' > "$SUBJECT/$REPLY.tmp"
        mv "$SUBJECT/$REPLY.tmp" "$SUBJECT/$REPLY.sort" 
    done <<< $(ls -1v "$SUBJECT" | grep -v 'sort')
    # exit
done

find -name '.sort' -size  0 -print -delete
find . -type d -empty -delete

} 2>&1 | tee get.LOG