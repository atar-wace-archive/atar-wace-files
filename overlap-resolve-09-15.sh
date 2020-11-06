DIR1=./WACE_old_09-15
DIR2=./WACE_old_09-10_CC
DIR3=./WACE_old_arc
DIR4=./AUTOPATCH
OUT=./WACE_old_RESOLVED

mkdir -p "$OUT"

#https://web.archive.org/web/20091020001756/https://www.awinfosys.com/WACE/practice/index.htm Should we archive these online (electronic) exams? The direct link still works all these years later!
#Note that we're assuming that both dirs have the same common subjects and same formatting.
time {
for SUBJECT in $(find "$DIR1" -type d | sed 's|.*/||' | tail -n+2); do
    echo $SUBJECT
    # ls "$DIR2/$SUBJECT"
    mkdir -p "$OUT/$SUBJECT"
    for YEAR in 2009 2010 2011 2012 2013 2014 2015; do
        echo "$YEAR"
        # if [ -a "$DIR2/$SUBJECT/$YEAR.sort" ]; then
        #     if [ -a "$DIR1/$SUBJECT/$YEAR.sort" ]; then
        #         #Conflict resolve here
        #         echo CONFLICT $YEAR
                DIRS=()
                if [ -a "$DIR3/$SUBJECT/$YEAR" ]; then
                    DIRS=(${DIRS[@]} "$DIR3/$SUBJECT/$YEAR")
                fi
                if [ -a "$DIR1/$SUBJECT/$YEAR" ]; then
                    DIRS=(${DIRS[@]} "$DIR1/$SUBJECT/$YEAR")
                fi
                if [ -a "$DIR2/$SUBJECT/$YEAR" ]; then
                    DIRS=(${DIRS[@]} "$DIR2/$SUBJECT/$YEAR")
                fi
                if [ -a "$DIR4/$SUBJECT/$YEAR" ]; then
                    DIRS=(${DIRS[@]} "$DIR4/$SUBJECT/$YEAR")
                fi
                if [ ${#DIRS[@]} -gt 0 ]; then
                    cat ${DIRS[@]} | sort -t'^' -k1 -u -f > "$OUT/$SUBJECT/$YEAR"
                    # rm "$OUT/$SUBJECT/$YEAR.tmp"
                    c=1
                    while [ $c -le $(wc -l < "$OUT/$SUBJECT/$YEAR") ]; do
                        # echo "$REPLY"
                        test="$(awk 'NR=='$c "$OUT/$SUBJECT/$YEAR" | sed 's|.*/||')"
                        if [ "$(grep "$test" "$OUT/$SUBJECT/$YEAR")" ]; then
                            echo "$test"
                            awk '!/'"${test}"'$/ || !f++' "$OUT/$SUBJECT/$YEAR" > "$OUT/$SUBJECT/$YEAR.tmp" #NEED TO ADD BACK THE SORTING FUNCTIONALITY!!! NOT ACTUALLY SORTED BY FILENAME (??? Need to be verified??? Is this a problem?)
                            mv "$OUT/$SUBJECT/$YEAR.tmp" "$OUT/$SUBJECT/$YEAR"
                        fi
                        ((c++))
                    done
                    sort -t'^' -k1 -u -f "$OUT/$SUBJECT/$YEAR" | cut -d'^' -f2- | sed 's|"$||' > "$OUT/$SUBJECT/$YEAR.sort"
                    rm "$OUT/$SUBJECT/$YEAR"
                fi
        #     else
        #         echo No conflict: ATTEMPT COPY from "$DIR2" $YEAR
        #         cp "$DIR2/$SUBJECT/$YEAR.sort" "$OUT/$SUBJECT/$YEAR.sort"
        #     fi
        # else
        #     echo No conflict: ATTEMPT COPY from "$DIR1" $YEAR
        #     cp "$DIR1/$SUBJECT/$YEAR.sort" "$OUT/$SUBJECT/$YEAR.sort"
        # fi
    done
done
} | tee resolve.log