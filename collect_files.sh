#!/bin/bash

MAX_DEPTH=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --max_depth)
            MAX_DEPTH=( -maxdepth "$2" )
            shift 2
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"
INPUT_DIR="$1"
OUTPUT_DIR="$2"

if [[ ! -d "$INPUT_DIR" || ! -d "$OUTPUT_DIR" ]]; then
    echo "Ошибка: укажите две директории"
    exit 1
fi

declare -A file_counts

find_args=( "$INPUT_DIR" )
if [[ ${#MAX_DEPTH[@]} -gt 0 ]]; then
    find_args+=( "${MAX_DEPTH[@]}" )
fi
find_args+=( -type f )

while read -r filepath; do
    filename=$(basename "$filepath")

    count=${file_counts[$filename]:-0}
    ((count++))
    file_counts[$filename]=$count

    name="${filename%.*}"
    ext="${filename##*.}"

    if [[ "$filename" == "$ext" ]]; then
        newname="${name}"
        [[ $count -gt 1 ]] && newname="${name}${count}"
    else
        newname="${name}"
        [[ $count -gt 1 ]] && newname="${name}${count}"
        newname="${newname}.${ext}"
    fi

    cp "$filepath" "$OUTPUT_DIR/$newname"
done < <(find "${find_args[@]}")
