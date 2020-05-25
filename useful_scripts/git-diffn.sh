#!/bin/bash

# This file is part of eRCaGuy_dotfiles: https://github.com/ElectricRCAircraftGuy/eRCaGuy_dotfiles

# Author: Gabriel Staples
# Status: IT WORKS! USE AS A COMPLETE, 100% SYNTAX-COMPATIBLE, DROP-IN REPLACEMENT FOR `git diff`!
#         See details just below.

# git-diffn.sh
# - a drop-in replacement for `git diff` which also shows line 'n'umbers! Use it *exactly* like
#   `git diff`, except you'll see these beautiful line numbers as well to help you make sense of
#   your changes. 
# - since it's just a light-weight awk-language-based wrapper around `git diff`, it accepts ALL 
#   options and parameters that `git diff` accepts. Examples:
#   - `git diffn HEAD~`
#   - `git diffn HEAD~3..HEAD~2`
# - ###############works with any of your `git diff` color settings, even if you are using custom colors
#   - See my answer here for how to set custom diff colors:
#     https://stackoverflow.com/questions/26941144/how-do-you-customize-the-color-of-the-diff-header-in-git-diff/61993060#61993060
#   - Ex:
#       git config --global color.diff.meta "blue"
#       git config --global color.diff.old "black red strike"
#       git config --global color.diff.new "black green italic"
# - color is ON by default; if you want to disable the output color, you must use
#   `--no-color` or `--color=never`. See `man git diff` for details. Examples: 
#   - `git diffn --color=never HEAD~`
#   - `git diffn --no-color HEAD~3..HEAD~2`

# INSTALLATION INSTRUCTIONS:
# 1. Create a symlink in ~/bin to this script so you can run it from anywhere as `git diffn` OR
#    as `git-diffn` OR as `gs_git-diffn` OR as `git gs_diffn`. Note that "gs" is my initials. 
#    I do these versions with "gs_" in them so I can find all scripts I've written really easily 
#    by simply typing "gs_" + Tab + Tab, or "git gs_" + Tab + Tab. 
#       cd /path/to/here
#       mkdir -p ~/bin
#       ln -si "${PWD}/git-diffn.sh" ~/bin/git-diffn     # required
#       ln -si "${PWD}/git-diffn.sh" ~/bin/git-gs_diffn  # optional; replace "gs" with your initials
#       ln -si "${PWD}/git-diffn.sh" ~/bin/gs_git-diffn  # optional; replace "gs" with your initials
# 2. Now you can use this command directly anywhere you like in any of these 5 ways:
#   1. `git diffn`  <=== my preferred way to use this program, so it feels just like `git diff`!
#   2. `git-diffn`
#   3. `git gs_diffn`
#   4. `git-gs_diffn`
#   3. `gs_git-diffn`

# References:
# 1. This script borrows from @PFudd's script here:
#    https://stackoverflow.com/questions/24455377/git-diff-with-line-numbers-git-log-with-line-numbers/33249416#33249416
# 2. @PFudd expands on @Andy Talkowski's code from here:
#    https://stackoverflow.com/questions/24455377/git-diff-with-line-numbers-git-log-with-line-numbers/32616440#32616440
# 3. I also received help from @Ed Morton and @Inian here: 
#    https://stackoverflow.com/questions/61932427/git-diff-with-line-numbers-and-proper-code-alignment-indentation
# 4. And then I did a crap-ton of research all over the place, with most of it being in the official GNU Awk (gawk) 
#    manual here: https://www.gnu.org/software/gawk/manual/html_node/index.html#SEC_Contents

# Awk-language-specific References:
# 1. Great awk intro, description, & examples to get started!: https://en.wikipedia.org/wiki/AWK
# 1. awk cheatsheet: https://www.shortcutfoo.com/app/dojos/awk/cheatsheet
# 1. How to obtain a matched substring in awk; see here:
#   1. https://stackoverflow.com/questions/5536018/how-to-print-matched-regex-pattern-using-awk/5536342#5536342
#     1. Also be sure to read the references he posts to the gawk manual!
#   2. and here: https://stackoverflow.com/questions/5536018/how-to-print-matched-regex-pattern-using-awk/30641727#30641727
# 1. *****"The Essential Syntax of AWK": https://www.grymoire.com/Unix/Awk.html#uh-5
# 1. https://www.gnu.org/software/gawk/manual/html_node/Using-Shell-Variables.html
# 1. Dynamic Regexps: https://www.gnu.org/software/gawk/manual/html_node/Computed-Regexps.html
# 1. https://www.gnu.org/software/gawk/manual/html_node/Quoting.html
# 1. awk print: https://www.gnu.org/software/gawk/manual/html_node/Print.html 
# 1. awk printf: https://www.gnu.org/software/gawk/manual/html_node/Basic-Printf.html
# 1. awk printf examples: https://www.gnu.org/software/gawk/manual/html_node/Printf-Examples.html
#   1. Sample data files for all awk examples: https://www.gnu.org/software/gawk/manual/html_node/Sample-Data-Files.html#Sample-Data-Files
# 1. awk `next` statement: https://www.gnu.org/software/gawk/manual/html_node/Next-Statement.html
# 1. awk String Functions: https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html; Including:
#   1. gsub()
#   1. match()
#   1. gensub()
#   1. etc. 
# 1. awk `next` statement: https://www.gnu.org/software/gawk/manual/html_node/Next-Statement.html
# 1. awk variable and shell variable usage
#   1. see the last example here:
#      https://www.gnu.org/software/gawk/manual/html_node/Printf-Examples.html
#   1. and also this info here: 
#      https://www.gnu.org/software/gawk/manual/html_node/Using-Shell-Variables.html
# 1. See also my Q & the answers & comments here: 
#    https://stackoverflow.com/questions/61932427/git-diff-with-line-numbers-and-proper-code-alignment-indentation

# Awk-language Notes:
# The gist of awk: pattern {action}
#  - See here: https://en.wikipedia.org/wiki/AWK
# Meaning of tidle (~): "matches a regular expression against a string" (https://en.wikipedia.org/wiki/AWK)
#  - Can be read as: "check the operands on either side to see if they match" (http://billconner.com/techie/awk.html)
#  - See also here: https://www.grymoire.com/Unix/Awk.html#uh-11
#  - Ex:  `my_var ~ /regex/ { action }` means: "if the contents of my_var has a match against 
#    the regular expression "regex", then do `action`".

# IMPORTANT: SINCE I'M USING SINGLE QUOTES (' ') AROUND THE WHOLE AWK PROGRAM BELOW, ***NO***
# UNESCAPED SINGLE QUOTES ARE ALLOWED IN THE CODE BELOW, ***INCLUDING IN AWK COMMENTS!*** Since 
# this comment says "I'm" in it, if you move it down into the awk code below, it will make the awk
# code fail to run too!

# ANSI Color Code Examples to help make sense of the regex expressions below
# Git config color code descriptions; see here:
# https://stackoverflow.com/questions/26941144/how-do-you-customize-the-color-of-the-diff-header-in-git-diff/61993060#61993060
#            --------------     ---------------------------------------------------------
#                               Git config color code desription
#            ANSI Color Code    text_color(x1) background_color(x1) attributes(0 or more)
#            ---------------    ---------------------------------------------------------
# COLOR_OFF="\033[m"            # code to turn off or "end" the previous color code
# COLOR_WHT="\033[1m"           # "white"
# COLOR_RED="\033[31m"          # "red"
# COLOR_GRN="\033[32m"          # "green"
# COLOR_GRN="\033[33m"          # "yellow"
# COLOR_GRN="\033[34m"          # "blue"
# COLOR_TEA="\033[36m"          # "cyan"
# COLOR_YLB="\033[1;33m"        # "yellow bold"
# COLOR_YLB="\033[1;36m"        # "cyan bold"
# COLOR_YLB="\033[3;30;42m"     # "black green italic" = black text with green background, italic text
# COLOR_YLB="\033[9;30;41m"     # "black red strike" = black text with red background, strikethrough line through the text

# Use this website to help you decipher and build regular expressions: https://regex101.com/

# A regex expression to match any of the "single code" (text color only) color codes above, 
# including `1m` through `99m`, is as follows:
#       ^(\033\[[0-9]{1,2}m)?

# Now, expanding upon that, here's a regexp which can handle "multiple code" (text color (x1) +
# background color (x1) + attributes (0 or more)) color codes, with 1 to 10 groups of "1;", "30;",
# "41", "42", etc. codes is this:
#       ^(\033\[(([0-9]{1,2};?){1,10})m)?

git diff --color=always "$@" | \
gawk \
'
# -------------------------------
# Awk Program Start
# -------------------------------

BEGIN {
    # color code to turn color OFF at this location in a string
    COLOR_OFF = "\033[m"
    # color off code being used during printing; will be set to COLOR_OFF once color_L OR 
    # color_R is detected
    color_off = ""
    # color code for the left side, or lines deleted (-); this will be auto-detected later
    color_L = ""
    # color code for the right side, or lines added (+); this will be auto-detected later
    color_R = ""
    # true if the -/left (deletion) color code is known; false otherwise
    color_L_known = "false"
    # true if the +/right (addition) color code is known; false otherwise
    color_R_known = "false"
    # set to true to indicate `git diff` output color is ON, or false otherwise; assume it is
    # on to start, then we will change this setting if necessary once we detect it is off
    color_is_on = "true"
}

{
    raw_line = $0
}

# 1. First, find an uncolored or teal-colored line like this `@@ -159,6 +159,13 @@` which 
# indicates the line numbers
match(raw_line, /^(\033\[(([0-9]{1,2};?){1,10})m)?@@ -([0-9]+),[0-9]+ \+([0-9]+),[0-9]+ @@/, array) {
    # The array indices below are according to the parenthetical group number in the regex
    # above; see: 
    # https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html#index-match_0028_0029-function
    left_num = array[2]  # left (deletion) starting line number
    right_num = array[3] # right (additiona) starting line number
    print raw_line
    # printf "===left_num = %i, right_num = %i===\n", left_num, right_num # for debugging
    next
}

# 2. Match uncolored or white `--- a/my/file` and 
#                             `+++ b/my/file` type lines, as well as ANY OTHER LINE WHICH DOES
# *NOT* BEGIN WITH A -, +, or space (optional color code at the start accounted for).
match(raw_line, /^(\033\[(([0-9]{1,2};?){1,10})m)?(---|\+\+\+|[^-+ \033])/) {
    print raw_line
    next 
}

# 3. Match lines beginning with a minus (`-`), plus (`+`), or space (` `), optionally with
# a color code in front of them too

# lines deleted (-)
# Check to see if raw_line matches this regexp
/^(\033\[(([0-9]{1,2};?){1,10})m)?-/ {
    # Detect the color code if we dont yet know it
    if (color_is_on == "true" && color_L_known == "false") {
        match_index = match(raw_line, /^(\033\[(([0-9]{1,2};?){1,10})m)?/, array)
        if (match_index > 0) {
            # `git diff` color is ON, so lets save the color being used!
            # Index zero stores the string matched by regexp: "...the zeroth element of array 
            # is set to the entire portion of string matched by regexp." See:
            # https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html#index-match_0028_0029-function
            color_L = array[0] # left color code (for deleted lines -)
            color_off = COLOR_OFF
            color_L_known = "true"
        }
        else {
            # `git diff` color is NOT ON
            color_is_on = "false"
        }
    }

    # Print a **deleted line** with the appropriate colors based on whatever `git diff` is using
    printf color_L"-%+4s     "color_off":"color_L"%s\n", left_num, raw_line
    left_num++
    next
}

# lines added (+)
# Check to see if raw_line matches this regexp
/^(\033\[(([0-9]{1,2};?){1,10})m)?\+/ {
    # Detect the color code if we dont yet know it
    if (color_is_on == "true" && color_R_known == "false") {
        match_index = match(raw_line, /^(\033\[(([0-9]{1,2};?){1,10})m)?/, array)
        if (match_index > 0) {
            # `git diff` color is ON, so lets save the color being used!
            # Index zero stores the string matched by regexp: "...the zeroth element of array 
            # is set to the entire portion of string matched by regexp." See:
            # https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html#index-match_0028_0029-function
            color_R = array[0] # left color code (for deleted lines -)
            color_off = COLOR_OFF
            color_R_known = "true"
        }
        else {
            # `git diff` color is NOT ON
            color_is_on = "false"
        }
    }

    # Print an **added line** with the appropriate colors based on whatever `git diff` is using
    printf color_R"+     %+4s"color_off":"color_R"%s\n", right_num, raw_line
    right_num++
    next
}

# lines not changed (begin with an empty space ` `)
# These lines have no color or other attribute formatting by default (such as bold, italics, etc),
# but the user can add this in the git config settings if desired, so we must be able to handle
# color and attribute formatting on this text too.
# Check to see if raw_line matches this regexp
/^(\033\[(([0-9]{1,2};?){1,10})m)? / {
    printf " %+4s,%+4s:%s\n", left_num, right_num, raw_line
    left_num++
    right_num++
    next
}

# 4. Error-checking for sanity: this code should never be reached
{
    print "=========== GIT DIFFN ERROR =============="
    print "THIS CODE SHOULD NEVER BE REACHED! If you see this, open up an issue for `git diffn`"
    print "  here: https://github.com/ElectricRCAircraftGuy/eRCaGuy_dotfiles/issues"
    print "Raw line: "raw_line
    print "=========================================="
}

# -------------------------------
# Awk Program End
# -------------------------------
# Note that we are piping the output to `less` with -R to interpret ANSI color codes, -F to 
# quit immediately if the output takes up less than one-screen, and -X to not clear
# the screen when less exits! This was `git diffn` will provide exactly identical behavior
# to what `git diff` does! See:
# 1. https://stackoverflow.com/questions/2183900/how-do-i-prevent-git-diff-from-using-a-pager/14118014#14118014
# 2. https://unix.stackexchange.com/questions/38634/is-there-any-way-to-exit-less-without-clearing-the-screen/38638#38638
' \
| less -R -F -X
