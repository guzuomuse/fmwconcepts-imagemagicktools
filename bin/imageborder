#!/bin/bash
#
# Developed by Fred Weinhaus 4/23/2009 .......... revised 4/27/2009
# 
# USAGE: imageborder [-s size] [-b blurring] [-m mixcolor] [-p percent] [-r rimcolor] [-t thickness] [-e effect] infile outfile
# USAGE: imageborder [-h or -help]
# 
# OPTIONS:
# 
# -s      size              size of border; WidthxHeight; default equals 10% 
#                           of min(imagewidth, imageheight) in both dimensions
# -b      blurring          blurring amount for border effect; integer>=0;
#                           default=3
# -m      mixcolor          color to mix with the image border; default=white
# -p      percent           mixing percent for the mixcolor; 0<=integer<=100;
#                           default=30
# -r      rimcolor          rim color between the original image and the image
#                           border; any valid IM color is allowed; default=white
# -t      thickness         rim thickness; integer>=0; default=1
# -e      effect            image border effect; choices are edge, mirror, 
#                           magnify, tile, random, dither or average; default=edge
# 
###
# 
# NAME: IMAGEBORDER 
# 
# PURPOSE: To append an image border by extending the outer regions of the image.
# 
# DESCRIPTION: IMAGEBORDER appends an image border by extending the outer regions 
# of the image. Thus the output image will be larger than the input image and no 
# area of the input image will be covered. The extended border can be blurred, 
# mixed with some other color and can either extend the outer row and column or 
# mirror the outer area of the image to create the border effect. A rim color 
# can also be placed around the original image.
# 
# 
# ARGUMENTS: 
# 
# -s size ... SIZE (WidthxHeight) is the size or dimensions of the border region. 
# Values are integers greater than 0. Size can be specified as one value that 
# will be used all around or as two values delimeted with an "x". The first 
# value will be the border size in the width dimension and the second will be 
# the border size in the height dimension. The default is to use one value all 
# around that is 10% of the min(width,height) of the image.
# 
# -b blurring ... BLURRING is the amount of blur to apply to the border region. 
# Values are integers>=0. The default=3
# 
# -m mixcolor ... MIXCOLOR is the color to mix with the image border. 
# Any valid IM color may be used. The default is white.
# 
# -p percent ... PERCENT is the percent of the mixcolor to blend with 
# the image border. Values are integers such that 0<=percent<=100. 
# The default is 30.
# 
# -r rimcolor ... RIMCOLOR is the color of the rim to place around the 
# original image. Any valid IM color may be used. The default is white.
# 
# -t thickness ... THICKNESS is the thickness of the rim around the 
# original image. Values are integers>=0. The default=1.
# 
# -e effect ... EFFECT specifies the type of image border effect to use.
# The choices are edge, mirror, magnify, tile or random. If edge is
# specified, then the top, right, bottom and left row/column of the image
# will simply be extended by the size parameters to create the image
# border. If mirror is specified, then the outer size pixels from the
# image will be mirrored to produce the image border effect. If magnify is
# specified, then the border will be created from the magnified image. If
# tile is specified, then the border will be created from tiling the
# image. If random is specified, then the border will be made up of random
# pixels from the image. If dither is specified, then the border will be 
# created from a non-random 32x32 dithered pattern. If average is specified, 
# then the border will be created from the average color of the whole image.
# The default is edge.
# 
# NOTE: Requires IM 6.3.5-4 or higher due to the use of -distort SRT
# 
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
# 

# set default values
size=""				# WxH; default=10% of image min(w,h)
blurring=3			# blur sigma >= 0
mixcolor="white"	# mixing color
percent=30			# mixing percent 0<=percent<=100
rimcolor="white"	# rim color
thickness=1			# rim thickness >= 0
effect="edge"		# virtual-pixel: edge, mirror, magnify, tile, random

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
elif [ $# -gt 16 ]
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
				-s)    # get size
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID SIZE SPECIFICATION ---"
					   checkMinus "$1"
					   size="${1}x"
					   wsize=`echo "$size" | cut -dx -f1`
					   hsize=`echo "$size" | cut -dx -f2`
					   [ "$hsize" = "" ] && hsize=$wsize
					   wsize=`expr "$wsize" : '\([0-9]*\)'`
					   [ "$wsize" = "" ] && errMsg "--- WSIZE=$wsize MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   hsize=`expr "$hsize" : '\([0-9]*\)'`
					   [ "$hsize" = "" ] && errMsg "--- HSIZE=$hsize MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-b)    # get  blurring
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID BLURRING SPECIFICATION ---"
					   checkMinus "$1"
					   blurring=`expr "$1" : '\([0-9]*\)'`
					   [ "$blurring" = "" ] && errMsg "--- BLURRING=$blurring MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-m)    # get  mixcolor
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID MIXCOLOR SPECIFICATION ---"
					   checkMinus "$1"
					   mixcolor="$1"
					   ;;
				-p)    # get percent
					   shift  # to get the next parameter - radius,sigma
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID PERCENT SPECIFICATION ---"
					   checkMinus "$1"
					   percent=`expr "$1" : '\([0-9]*\)'`
					   [ "$percent" = "" ] && errMsg "--- PERCENT=$percent MUST BE A NON-NEGATIVE INTEGER ---"
					   percenttestA=`echo "$percent < 0" | bc`
					   percenttestB=`echo "$percent > 100" | bc`
					   [ $percenttestA -eq 1 -o $percenttestB -eq 1 ] && errMsg "--- PERCENT=$percent MUST BE AN INTEGER BETWEEN 0 AND 100 ---"
					   ;;
				-r)    # get rimcolor
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID RIMCOLOR SPECIFICATION ---"
					   checkMinus "$1"
					   rimcolor="$1"
					   ;;
				-t)    # get thickness
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID THICKNESS SPECIFICATION ---"
					   checkMinus "$1"
					   thickness=`expr "$1" : '\([0-9]*\)'`
					   [ "$thickness" = "" ] && errMsg "--- THICKNESS=$thickness MUST BE A NON-NEGATIVE INTEGER VALUE (with no sign) ---"
					   ;;
				-e)    # get effect
					   shift  # to get the next parameter - type
					   # test if parameter starts with minus sign
					   errorMsg="--- INVALID EFFECT SPECIFICATION ---"
					   checkMinus "$1"
					   # test type values
					   effect="$1"
					   case "$effect" in
							edge|mirror|tile|random|magnify|dither|average) ;; # do nothing - valid type
							*)  errMsg "--- EFFECT=$effect IS NOT A VALID VALUE ---" ;;
					   esac
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

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"


tmpA="$dir/imageborder_$$.mpc"
tmpB="$dir/imageborder_$$.cache"
trap "rm -f $tmpA $tmpB; exit 0" 0
trap "rm -f $tmpA $tmpB; exit 1" 1 2 3 15


# read the input image into the TMP cached image.
convert -quiet -regard-warnings "$infile" +repage "$tmpA" ||
  errMsg "--- FILE $infile NOT READABLE OR HAS ZERO SIZE ---"

# set default size
if [ "$size" = "" ]; then
	size=`convert $tmpA -ping -format "%[fx:floor(0.1*min(w,h))]" info:`
	wsize=$size
	hsize=$size
fi

# set output image size
ww=`convert $tmpA -ping -format "%[fx:w+2*$wsize]" info:`
hh=`convert $tmpA -ping -format "%[fx:h+2*$hsize]" info:`

# set magnification
if [ "$effect" = "magnify" ]; then
	effect="edge"
	xmag=`convert $tmpA -ping -format "%[fx:$ww/w]" info:`
	ymag=`convert $tmpA -ping -format "%[fx:$hh/h]" info:`
else
	xmag=1
	ymag=1
fi

# set position for blurring
if [ "$effect" = "random" -o "$effect" = "dither" ]; then
	blurring1=""
	blurring2="-blur 0x${blurring}"
else
	blurring1="-blur 0x${blurring}"
	blurring2=""
fi

# setup for using average color 
if [ "$effect" = "average" ]; then
	effect="background"
	bgcolor=`convert \( zelda3.jpg -scale 1x1! \) -format "rgb(%[fx:100*u.p{0,0}.r]%%,%[fx:100*u.p{0,0}.g]%%,%[fx:100*u.p{0,0}.b]%%)" info:`
	backgroundcoloring="-background $bgcolor"
	colorization1=""
	colorization2="-fill $mixcolor -colorize ${percent}%"
else
	backgroundcoloring=""
	colorization1="-fill $mixcolor -colorize ${percent}%"
	colorization2=""
fi


# process the image
convert $tmpA \
	\( -clone 0 $blurring1 $colorization1 \
	-set option:distort:viewport ${ww}x${hh}-${wsize}-${hsize} \
	$backgroundcoloring -virtual-pixel $effect \
	-distort SRT "0,0 $xmag,$ymag 0" $blurring2 $colorization2 \) \
	\( -clone 0 -bordercolor $rimcolor -border $thickness \) \
	-delete 0 -gravity center -compose over -composite \
	$outfile
exit 0
