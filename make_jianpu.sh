#!/bin/bash

script_name="make_jianpu.sh"
script_usage=$(cat <<EOF
make_jianpu.sh [OPTIONS] JIANPU.txt
EOF
)
script_function=$(cat <<EOF
Batch convertion of a jianpu into Lilypond script then into pdf, png, midi and wav
EOF
)
script_doc=$(cat <<EOF
-h     Display this help.
EOF
)
script_examples=$(cat <<EOF
EOF
)
state_prefix="==="
warning_prefix="***"
error_prefix="!!!"

function display_help() {
    if [ -n "$script_usage" ]; then
    echo -e "Usage: $script_usage"
    fi
    
    if [ -n "$script_function" ]; then
    echo -e "$script_function"
    fi
    
    if [ -n "$script_doc" ] ; then
    echo -e "\n$script_doc"
    fi
}

while getopts ":hr:" opt; do
    case $opt in
    h  )  display_help
        exit 0 ;;
    \? )  display_help
        exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

jianpu_txt="$1"

# Clear old generated files
if [ -e "${jianpu_txt%txt}ly" ]; then
    rm "${jianpu_txt%txt}ly"
fi

if [ -e "${jianpu_txt%txt}pdf" ]; then
    rm "${jianpu_txt%txt}pdf"
fi

if [ -e "${jianpu_txt%txt}png" ]; then
    rm "${jianpu_txt%txt}png"
fi

if [ -e "${jianpu_txt%txt}midi" ]; then
    rm "${jianpu_txt%txt}midi"
fi

if [ -e "${jianpu_txt%txt}wav" ]; then
    rm "${jianpu_txt%txt}wav"
fi

if [ -e "$jianpu_txt"  ]; then
    jianpu-ly.py < "$jianpu_txt" > "${jianpu_txt%txt}ly"

    if [ -e "${jianpu_txt%txt}ly" ]; then
        # Generate pdf file
        lilypond "${jianpu_txt%txt}ly"
        
        if [ -e "${jianpu_txt%txt}pdf" ]; then
            echo "简谱pdf文件生成成功！"

            # Generate png file
            lilypond --png "${jianpu_txt%txt}ly"

            if [ -e "${jianpu_txt%txt}png" ]; then
                echo "简谱图片文件生成成功！"

                # Generate wav file from midi   
                if [ -e "${jianpu_txt%txt}midi" ]; then
                    echo "midi文件生成成功！"

                    timidity -Ow -o "${jianpu_txt%txt}wav" "${jianpu_txt%txt}midi"

                    if [ -e "${jianpu_txt%txt}wav" ]; then
                        echo "wav文件生成成功！"
                    else
                        echo "无法生成wav文件，请检查简谱语法错误！"
                    fi
                else
                    echo "无法生成midi文件，请检查简谱语法错误！"
                fi
            else
                echo "无法生成简谱图片文件，请检查简谱语法错误！"
            fi 
        else
            echo "无法生成PDF文件，请检查简谱语法错误！"
        fi
    else
        echo "无法生成ly文件，请检查简谱语法错误！"
    fi
else
    echo "无法找到输入文件：$jianpu_txt！"
fi
