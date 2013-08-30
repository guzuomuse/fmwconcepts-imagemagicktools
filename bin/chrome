#!/bin/bash
#
# Developed by Fred Weinhaus 4/10/2010 .......... revised 11/27/2011
# 
# USAGE: chrome [-i intensity] [-n numcycles] [-s smooth] [-a azimuth] [-e elevation] [-c color] [-b bgcolor] [-f fuzzfact] infile outfile
# USAGE: chrome [-h or -help]
# 
# OPTIONS:
# 
# -i      intensity         intensity of chrome effect; integer>=0; 
#                           default=100 (nominal)
# -n      numcycles         number of cycles in the chrome lookup table; 
#                           integer>0; default=2
# -s      smooth            smoothing amount; float>=0; default=3
# -a      azimuth           azimuth angle for light source; 0<=integer<=360; 
#                           counterclockwise from positive x axis (East);
#                           default=135 (NorthWest)
# -e      elevation         elevation angle for light source; 0<=integer<=90;
#                           upwards from x-y plane; default=45; only for method=1
# -c      color             color for chrome effect; any valid IM color; 
#                           default=no special coloration
# -b      bgcolor           background color outside chrome area; any valid 
#                           IM color including none for transparent
# -f      fuzzfact          percent fuzz factor for extracting the background 
#                           area; float>=0; default=1
# 
###
# 
# NAME: CHROME 
# 
# PURPOSE: To apply a chrome effect to a binary image.
# 
# DESCRIPTION: CHROME applies an chrome effect to a binary image. Coloration 
# is optional.
# 
# 
# ARGUMENTS: 
# 
# -i intensity ... INTENSITY of chrome effect. This brings out contrast.
# Values are integers>=0. The default=100 is the nominal values.
# 
# -n numcycles ... NUMCYCLES is the number of cycles in the chrome look up 
# table that controls the type of chrome effect. Values are integers>0. 
# The default=2.
# 
# -s smooth ... SMOOTH is the amount of smoothing to  apply to chrome effect. 
# Values are floats>=0. The default=3.
# 
# -a azimuth ... AZIMUTH is the angle in degrees in the x-y plane measured 
# counterclockwise from EAST to the light source. Values are integers in the 
# range 0<=azimuth<=360. The default=135 (NorthWest).
# 
# -e elevation ... ELEVATION is the angle in degrees upwards from the x-y plane 
# to the light source. Values are integers in the range 0<=elevation<=90. 
# The default=45.
# 
# -c color ... COLOR is the optional color to apply to the chrome effect. 
# Any valid IM color is allowed. The default is no additional color on top 
# of the natural chrome effect.
# 
# -b bgcolor ... BGCOLOR is the optional background color outside the chromed 
# items. Any valid IM color is allowed including none for transparency. 
# The default is no special background color.
# 
# -f fuzzfact ... FUZZFACT is the fuzz factor in percent used to extract the 
# background region for coloring. Values are floats>=0. The default=1.
# 
# REQUIREMENTS: IM 6.4.8-9 in order to support -function sinusoid.
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
smooth=3				#smoothing factor; float>=0
azimuth=135				#azimuth angle; 0<=integer<=360
elevation=45			#elevation angle: 0<=integer<=90
intensity=100			#intensity; integer>=0
numcycles=2				#number cycles; integer>0
color=""				#color for chrome
bgcolor=""				#background color
fuzzfact=1				#fuzzfactor for backround/foreground mask; float>=0

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
elif [ $# -gt 18 ]
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
				-i)    # get intensity
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID INTENSITY SPECIFICATION ---"
					   checkMinus "$1"
					   intensity=`expr "$1" : '\([0-9]*\)'`
					   [ "$intensity" = "" ] && errMsg "--- INTENSITY=$intensity MUST BE A NON-NEGATIVE INTEGER ---"
					   ;;
				-n)    # get numcycles
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID NUMCYCLES SPECIFICATION ---"
					   checkMinus "$1"
					   numcycles=`expr "$1" : '\([0-9]*\)'`
					   [ "$numcycles" = "" ] && errMsg "--- NUMCYCLES=$numcycles MUST BE A NON-NEGATIVE INTEGER ---"
					   test=`echo "$numcycles < 1" | bc`
					   [ $test -eq 1 ] && errMsg "--- NUMCYCLES=$numcycles MUST BE A POSITIVE INTEGER ---"
					   ;;
				-s)    # get smooth
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SMOOTH SPECIFICATION ---"
					   checkMinus "$1"
					   smooth=`expr "$1" : '\([.0-9]*\)'`
					   [ "$smooth" = "" ] && errMsg "--- SMOOTH=$smooth MUST BE A NON-NEGATIVE FLOAT ---"
					   ;;
				-a)    # get azimuth
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID AZUMUTH SPECIFICATION ---"
					   checkMinus "$1"
					   azimuth=`expr "$1" : '\([0-9]*\)'`
					   [ "$azimuth" = "" ] && errMsg "--- AZUMUTH=$azimuth MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   test1=`echo "$azimuth < 0" | bc`
					   test2=`echo "$azimuth > 360" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- AZUMUTH=$azimuth MUST BE AN INTEGER BETWEEN 0 AND 360 ---"
					   ;;
				-e)    # get elevation
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID ELEVATION SPECIFICATION ---"
					   checkMinus "$1"
					   elevation=`expr "$1" : '\([0-9]*\)'`
					   [ "$elevation" = "" ] && errMsg "--- ELEVATION=$elevation MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   test1=`echo "$elevation < 0" | bc`
					   test2=`echo "$elevation > 90" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- ELEVATION=$elevation MUST BE AN INTEGER BETWEEN 0 AND 90 ---"
					   ;;
				-c)    # get color
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID COLOR SPECIFICATION ---"
					   checkMinus "$1"
					   color="$1"
					   ;;
				-b)    # get bgcolor
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID BGCOLOR SPECIFICATION ---"
					   checkMinus "$1"
					   bgcolor="$1"
					   ;;
				-f)    # get fuzzfact
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID FUZZFACT SPECIFICATION ---"
					   checkMinus "$1"
					   fuzzfact=`expr "$1" : '\([.0-9]*\)'`
					   [ "$fuzzfact" = "" ] && errMsg "--- FUZZFACT=$fuzzfact MUST BE A NON-NEGATIVE FLOAT ---"
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


# setup temporary images and auto delete upon exit
tmpA1="$dir/chrome_1_$$.mpc"
tmpB1="$dir/chrome_1_$$.cache"
tmpA2="$dir/chrome_2_$$.mpc"
tmpB2="$dir/chrome_2_$$.cache"
tmpA3="$dir/chrome_3_$$.mpc"
tmpB3="$dir/chrome_3_$$.cache"
tmpA4="$dir/chrome_3_$$.mpc"
tmpB4="$dir/chrome_3_$$.cache"
trap "rm -f $tmpA1 $tmpB1 $tmpA2 $tmpB2 $tmpA3 $tmpB3 $tmpA4 $tmpB4; exit 0" 0
trap "rm -f $tmpA1 $tmpB1 $tmpA2 $tmpB2 $tmpA3 $tmpB3 $tmpA4 $tmpB4; exit 1" 1 2 3 15

# read the input image and filter image into the temp files and test validity.
convert -quiet -regard-warnings "$infile" +repage "$tmpA1" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO SIZE  ---"


# get IM version
im_version=`convert -list configure | \
	sed '/^LIB_VERSION_NUMBER /!d; s//,/;  s/,/,0/g;  s/,0*\([0-9][0-9]\)/\1/g' | head -n 1`
[ "$im_version" -lt "06040809" ] && errMsg "--- IM VERSION IS NOT COMPATIBLE ---"


amp0=`convert xc: -format "%[fx:$intensity/100]" info:`
amp1=`convert xc: -format "%[fx:$amp0/($amp0+1)]" info:`
amp2=`convert xc: -format "%[fx:1/($amp0+1)]" info:`
cyc=`convert xc: -format "%[fx:0.5+$numcycles]" info:`

# create lut
convert \( -size 1x100 gradient: -rotate 90 \) \
	\( -clone 0 -function sinusoid $cyc,-90,0.5,0.5 \) \
	\( -clone 1 -evaluate multiply $amp1 \) \
	\( -clone 0 -evaluate multiply $amp2 \) \
	-delete 0,1 -compose plus -composite \
	$tmpA2

# set up levelcolors
if [ "$color" = "" ]; then
	colorize=""
else
	colorize="+level-colors black,${color}"
fi

# set up stretch
if [ "$im_version" -lt "06050501" ]; then
	stretch="-contrast-stretch 0"
else
	stretch="-auto-level"
fi

# create chrome image	
convert $tmpA1 -colorspace gray -blur 0x$smooth \
	-shade ${azimuth}x${elevation} $stretch $tmpA3
convert $tmpA3 $tmpA2 -clut $colorize $tmpA4

# process background if needed
if [ "$bgcolor" = "" ]; then
	convert $tmpA4 $outfile
else
	# set up fuzzify
	if [ $fuzzfact -eq 0 ]; then
		fuzzify=""
	else
		fuzzify="-fuzz $fuzzfact%"
	fi

	# set up bgcolorize
	if [ "$bgcolor" = "none" ]; then
		bgcolorize=""
	else
		bgcolorize="-compose over -background $bgcolor -flatten"
	fi

	convert $tmpA4 \
		\( $tmpA3 $fuzzify -fill black -draw "color 0,0 floodfill" -fill white +opaque black \) \
		-alpha off -compose copy_opacity -composite $bgcolorize $outfile	
fi
exit 0





