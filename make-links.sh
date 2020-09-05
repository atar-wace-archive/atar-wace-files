ATAR=ATAR
ATAR_SAMPLE=ATAR_sample
WACE_OLD=WACE_old_RESOLVED
WACE_DRAFT=WACE_DRAFT_CC
PATCH=PATCH
OUT=ALL

rm -r "$OUT"
mkdir -p "$OUT"

base="$(shell cygpath -w "$PWD")"

for dir in $(find "$ATAR" -type d | tail -n+2); do
    echo "$OUT/$dir"
    mkdir -p "$OUT/${dir/*\//}"
    for year in $(ls -1v "$dir" | grep sort); do
        cmd //c mklink "$base\\${OUT/\//\\\\}\\${dir/*\//}\\$year" "$base\\${dir/\//\\}\\$year"
    done
done
for dir in $(find "$WACE_OLD" -type d | tail -n+2); do
    echo "$OUT/$dir"
    mkdir -p "$OUT/${dir/*\//}"
    for year in $(ls -1v "$dir" | grep sort); do
        cmd //c mklink "$base\\${OUT/\//\\\\}\\${dir/*\//}\\$year" "$base\\${dir/\//\\}\\$year"
    done
done
for dir in $(find "$PATCH" -type d | tail -n+2); do
    echo "$OUT/$dir"
    mkdir -p "$OUT/${dir/*\//}"
    for year in $(ls -1v "$dir" | grep sort); do
        cmd //c mklink "$base\\${OUT/\//\\\\}\\${dir/*\//}\\$year" "$base\\${dir/\//\\}\\$year"
    done
done
for dir in $(find "$ATAR_SAMPLE" -type d | tail -n+2); do
    echo "$OUT/$dir"
    cmd //c mklink "$base\\${OUT/\//\\\\}\\${dir/*\//}\\2015-2016_wace1516_samples.sort" "$base\\${dir/\//\\}\\sample.sort"
done
for dir in $(find "$WACE_DRAFT" -type d | tail -n+2); do
    echo "$OUT/$dir"
    cmd //c mklink //d "$base\\${OUT/\//\\\\}\\${dir/*\//}\\2007-2008_wace_draft.sort" "$base\\${dir/\//\\}\\"
done
# for dir in $(find "$WACE_OLD" -type d | tail -n+2); do
#     echo "$OUT/$dir"
#     mkdir -p "$OUT/${dir/*\//}"
#     cmd //c mklink "$base\\${OUT/\//\\\\}\\${dir/*\//}\\$year" "$base\\${dir/\//\\}\\$year"
# done