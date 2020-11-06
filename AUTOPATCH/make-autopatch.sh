for subject in $(find ../../atar-wace-papers-patched-files/ -maxdepth 1 -type d | tail -n+2 | grep -v .git); do
    target=${subject/..\/..\/atar-wace-papers-patched-files\//}
    mkdir -p $target
    for year in $(ls -1v $subject); do
        rm "$target/$year"
        while read; do
            item=$subject/$year/$REPLY
            case ${item/*./} in
                pdf)
                    type="application/pdf"
                    ;;
                mp3)
                    type="audio/mpeg"
                    ;;
                mp4)
                    type="video/mp4"
                    ;;
                docx)
                    type="application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    ;;
                doc)
                    type="application/msword"
                    ;;
                *)
                    type="default"
                    ;;
            esac
            echo "${item/*\//}^$type^${item/..\/..\/atar-wace-papers-patched-files/https:\/\/github.com\/atar-wace-archive\/atar-wace-papers-patched-files\/raw\/master}" >> "$target/$year"
        done <<< $(ls -1v $subject/$year)
        sort -t'^' -k1 -u -f "$target/$year" | cut -d'^' -f2- | sed 's|"$||' >"$target/$year.sort"
        case $year in
            [0-9][0-9][0-9][0-9])
                ;;
            *)
                m="../PATCH/$target/"
                mkdir -p "$m"
                mv "$target/$year.sort" "$m"
                mv "$target/$year" "$m"
                ;;
        esac
    done
done