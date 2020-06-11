#!/bin/bash

#   Copyright (C) 2012 University of Oxford
#
#   SHCOPYRIGHT

execpath=`dirname $0`
execpath=`realpath $execpath`


# last 2 parameters are subjdir and bindir
parameters=""
while [ ! -z "$2" ]
do
	case $1 in
          "--nf="*) numfib=`echo $1 | cut -d '=' -f2` ;;
        esac
 	all=$all" "$1
	subjdir=$1
	shift
done
bindir=$1  #unused, but keeping parsing as is.. AK

$execpath/merge_parts_gpu $all

fib=1
while [ $fib -le $numfib ]
do
    fslmaths ${subjdir}.bedpostX/merged_th${fib}samples -Tmean ${subjdir}.bedpostX/mean_th${fib}samples
    fslmaths ${subjdir}.bedpostX/merged_ph${fib}samples -Tmean ${subjdir}.bedpostX/mean_ph${fib}samples
    fslmaths ${subjdir}.bedpostX/merged_f${fib}samples -Tmean ${subjdir}.bedpostX/mean_f${fib}samples

    make_dyadic_vectors ${subjdir}.bedpostX/merged_th${fib}samples ${subjdir}.bedpostX/merged_ph${fib}samples ${subjdir}/nodif_brain_mask ${subjdir}.bedpostX/dyads${fib}
    if [ $fib -ge 2 ];then
	maskdyads ${subjdir}.bedpostX/dyads${fib} ${subjdir}.bedpostX/mean_f${fib}samples
	fslmaths ${subjdir}.bedpostX/mean_f${fib}samples -div ${subjdir}.bedpostX/mean_f1samples ${subjdir}.bedpostX/mean_f${fib}_f1samples
	fslmaths ${subjdir}.bedpostX/dyads${fib}_thr0.05 -mul ${subjdir}.bedpostX/mean_f${fib}_f1samples ${subjdir}.bedpostX/dyads${fib}_thr0.05_modf${fib}
	imrm ${subjdir}.bedpostX/mean_f${fib}_f1samples
    fi

    fib=$(($fib + 1))

done

if [ `imtest ${subjdir}.bedpostX/mean_f1samples` -eq 1 ];then
    fslmaths ${subjdir}.bedpostX/mean_f1samples -mul 0 ${subjdir}.bedpostX/mean_fsumsamples
    fib=1
    while [ $fib -le $numfib ]
    do
	fslmaths ${subjdir}.bedpostX/mean_fsumsamples -add ${subjdir}.bedpostX/mean_f${fib}samples ${subjdir}.bedpostX/mean_fsumsamples
	fib=$(($fib + 1))
    done
fi



echo Removing intermediate files

if [ `imtest ${subjdir}.bedpostX/merged_th1samples` -eq 1 ];then
  if [ `imtest ${subjdir}.bedpostX/merged_ph1samples` -eq 1 ];then
    if [ `imtest ${subjdir}.bedpostX/merged_f1samples` -eq 1 ];then
      rm -rf ${subjdir}.bedpostX/diff_parts
      rm -rf ${subjdir}.bedpostX/data*
      rm -rf ${subjdir}.bedpostX/grad_dev*
    fi
  fi
fi

echo Creating identity xfm

xfmdir=${subjdir}.bedpostX/xfms
echo 1 0 0 0 > ${xfmdir}/eye.mat
echo 0 1 0 0 >> ${xfmdir}/eye.mat
echo 0 0 1 0 >> ${xfmdir}/eye.mat
echo 0 0 0 1 >> ${xfmdir}/eye.mat

echo Done
