$out_dir = 'build';

END {
    system("cp build/main.pdf .") if -e "build/main.pdf";
}