#!/bin/bash
#
# Developed by Fred Weinhaus 7/22/2010 .......... revised 11/19/2010
# 
# USAGE: locatecolors -b begincolor -e endcolor [-m mode] infile outfile
# USAGE: locatecolors [-h or -help]
# 
# OPTIONS:
# 
# -b      begincolor        first color for range of colors; any valid 
#                           IM opaque color
# -e      endcolor          second color for range of colors; any valid 
#                           IM opaque color
# -m      mode              mode for combining channel ranges into mask;
#                           choices are: "and" or "or"; for "and" use 
#                           overlap of channel color ranges; for "or" use
#                           all ranges independently; default=and
# 
###
# 
# NAME: LOCATECOLORS 
# 
# PURPOSE: To modify an image to show only those pixels which are within 
# the specified color range.
# 
# DESCRIPTION: LOCATECOLORS modifies an image to show only those pixels which 
# are within the specified color range. A count of the number of pixels will 
# be presented at the terminal.
# 
# 
# ARGUMENTS: 
# 
# -b begincolor ... BEGINCOLOR is the first color used to specify the desired 
# range of colors. Any valid IM opaque color is allowed.
# 
# -e endcolor ... ENDCOLOR is the second color used to specify the desired 
# range of colors. Any valid IM opaque color is allowed.
# 
# -m mode ... MODE specifies how the ranges of colors are to be combined into 
# a mask. Choices are: "and" or "or". If "and" is specified, then the mask will 
# be created only where the channels overlap. If "or" is specified, then the 
# mask will be created from the sum of all the channel ranges. The default=and.
# 
# Note: the channel ranges will be manipulated in 8-bit colors to create 
# the mask.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
begincolor=""			# no default value
endcolor=""				# no default value
mode="and"			# "and" or "or"

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -n '/^###/q;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -n '/^######/q;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}


# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}


# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 8 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -h|-help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-m)    # get mode
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign
					   errorMsg="--- INVALID MODE SPECIFICATION ---"
					   checkMinus "$1"
					   # test type values
					   mode=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$mode" in
							and|or) ;; # do nothing - valid type
							*)  errMsg "--- MODE=$mode IS NOT A VALID VALUE ---" ;;
					   esac
					   ;;
				-b)    # get begincolor
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID BEGINCOLOR SPECIFICATION ---"
					   checkMinus "$1"
					   begincolor="$1"
					   ;;
				-e)    # get endcolor
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID ENDCOLOR SPECIFICATION ---"
					   checkMinus "$1"
					   endcolor="$1"
					   ;;
				 -)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile=$1
	outfile=$2
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "NO OUTPUT FILE SPECIFIED"

# setup temp files
tmp1A="$dir/locatecolors_1_$$.mpc"
tmp1B="$dir/locatecolors_1_$$.cache"
tmp2A="$dir/locatecolors_2_$$.mpc"
tmp2B="$dir/locatecolors_2_$$.cache"
tmpR1="$dir/locatecolors_R_$$.mpc"
tmpR2="$dir/locatecolors_R_$$.cache"
tmpG1="$dir/locatecolors_G_$$.mpc"
tmpG2="$dir/locatecolors_G_$$.cache"
tmpB1="$dir/locatecolors_B_$$.mpc"
tmpB2="$dir/locatecolors_B_$$.cache"
trap "rm -f $tmp1A $tmp1B $tmp2A $tmp2B $tmpR1 $tmpR2 $tmpG1 $tmpG2 $tmpB1 $tmpB2; exit 0" 0
trap "rm -f $tmp1A $tmp1B $tmp2A $tmp2B $tmpR1 $tmpR2 $tmpG1 $tmpG2 $tmpB1 $tmpB2; exit 1" 1 2 3 15


# test input image
convert -quiet -regard-warnings "$infile" +repage "$tmp1A" ||
	errMsg  "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE  ---"


function rgbColor()
	{
	color=$1
	rgbcolor=""
	rgbcolor=`convert -size 1x1 xc:"$color" -alpha off -depth 8 txt:- | \
		sed -n 's/ *//g; s/^.*:.*[(]\([,0-9]*\)[)].*$/\1/p'`
	if [ "$rgbcolor" = "" ]; then
		echo "--- color=$color NOT A VALID COLOR ---"
	else
		RR=`echo "$rgbcolor" | cut -d, -f1`
		GG=`echo "$rgbcolor" | cut -d, -f2`
		BB=`echo "$rgbcolor" | cut -d, -f3`
	fi
	}


function procChannel()
	{
	val1=$1
	val2=$2
	if [ $val1 -eq 0 -a $val2 -eq 255 ]; then
		proc="-fill white -colorize 100%"
	elif [ $val1 -eq $val2 ]; then
		proc="-fill red -opaque rgb($val1,$val1,$val1) -fill black +opaque red -fill white -opaque red"
	else
		pct1=`convert xc: -format "%[fx:100*$val1/255]" info:`
		pct2=`convert xc: -format "%[fx:100*$val2/255]" info:`
		if [ "$pct2" = "100" ]; then 
			proc="-black-threshold $pct1% -fill white +opaque black"
		elif [ "$pct1" = "0" ]; then 
			proc="-fill rgb(1,1,1) -opaque black -white-threshold $pct2% -fill black -opaque white -fill white +opaque black"
		else
			proc="-black-threshold $pct1% -white-threshold $pct2% -fill black -opaque white -fill white +opaque black"
		fi
	fi
	}

# test if both colors provided
[ "$begincolor" = "" -o "$endcolor" = "" ] && errMsg  "--- TWO COLORS MUST BE SPECIFIED  ---"

# convert begincolor
rgbColor "$begincolor"
RR1=$RR
GG1=$GG
BB1=$BB
#echo "RR1=$RR1; GG1=$GG1; BB1=$BB1;"

# convert endcolor
rgbColor "$endcolor"
RR2=$RR
GG2=$GG
BB2=$BB
#echo "RR2=$RR2; GG2=$GG2; BB2=$BB2;"


# sort colors
if [ $RR1 -gt $RR2 ]; then
	RR=$RR1
	RR1=$RR2
	RR2=$RR
fi
if [ $GG1 -gt $GG2 ]; then
	GG=$GG1
	GG1=$GG2
	GG2=$GG
fi
if [ $BB1 -gt $BB2 ]; then
	BB=$BB1
	BB1=$BB2
	BB2=$BB
fi
#echo "RR1=$RR1; RR2=$RR2; GG1=$GG1; GG2=$GG2; BB1=$BB1; BB2=$BB2;"


# get channel processing
procChannel "$RR1" "$RR2"
redproc="$proc"
procChannel "$GG1" "$GG2"
greenproc="$proc"
procChannel "$BB1" "$BB2"
blueproc="$proc"
#echo "redproc=$redproc"
#echo "greenproc=$greenproc"
#echo "blueproc=$blueproc"


if [ "$mode" = "and" ]; then
	function="multiply"
elif [ "$mode" = "or" ]; then
	function="plus"
fi

# process image
convert $tmp1A -alpha off -colorspace rgb -depth 8 -separate \
	\( -clone 0 $redproc \) \
	\( -clone 1 $greenproc \) \
	\( -clone 2 $blueproc \) \
	-delete 0-2 \
	\( -clone 0 -clone 1 -compose $function -composite \
	-clone 2 -compose $function -composite \) \
	-delete 0-2 $tmp2A
	

# get count of matching colors
count=`convert $tmp2A -format "%[fx:floor(mean*w*h)]" info:`
percent=`convert $tmp2A -format "%[fx:100*mean]" info:`
echo ""
echo "Count Of Matching Pixels = $count"
echo "Percentage Of Matching Pixels = $percent%"
echo ""

convert $tmp1A $tmp2A -alpha off -compose copy_opacity -composite $outfile
exit 0