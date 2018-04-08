L3 - Creating image processing pipelines for novel sensor designs
==

The code here implements the work described in this patented work

https://patents.google.com/patent/US20120307116

Learning of Image Processing Pipeline for Digital Imaging Devices

## Abstract

A learning technique is provided that learns how to process images by exploiting the spatial and spectral correlations inherent in image data to process and enhance images. Using a training set of input and desired output images, regression coefficients are learned that are optimal for a predefined estimation function that estimates the values at a pixel of the desired output image using a collection of similarly located pixels in the input image. Application of the learned regression coefficients is fast, robust to noise, adapts to the particulars of a dataset, and generalizes to a large variety of applications. The invention enables the use of image sensors with novel color filter array designs that offer expanded capabilities beyond existing sensors and take advantage of typical high pixel counts.

## Linear, Local, Learned (L3)

The L3 toolbox (Matlab) was created to automate the construction of an image processing pipeline for novel sensor arrays.  These arrays might contain novel CFAs, or sensors with different dynamic ranges.

The scripts here show how to perform the training and testing of the L3 (Local, Linear, Learned) algorithm for automatic generation of image processing pipelines for arbitrary CFA measurement schemes for digital imaging sensors. The L3 pipeline performs demosaicking, denoising, and the color transform in one step.  The algorithm allows output estimated images to be in any user specified color bands.

The L3 software here relies on the ISETCAM software.

The tutorial scripts illustrating how to read, train and render are t_L3DataSimulation(); and t_L3DataISET;

For more instructions and references see this [temporary copy of the old wiki page](Scratch-from-old-pdc-wiki) and the [newer one under development](https://isetcam.git/isetcam/isetL3/wiki).


The scripts currently are written to run an example calculation for a 2x2 CFA containing red, green, blue, and white pixels.  The white pixel does not contain any filter and is much more sensitive to light, which allows imaging in low light.  Sample data containing images of faces is included to perform the calculation.

The following describes the contents of some of the folders of interest:

	-Data:  Contains some data files that can be used such as illuminants,
	 sensors, and reflectance images.  Any data can be used that is on the 
	 Matlab path but data should have the same format as these files.  

	-Results:  Learned L^3 pipeline files and estimated images will 
     	 automatically be saved in this folder.

	-Scripts to Show Results:  Contains a few scripts to display the 
     	 original and estimated images, the derived filters, etc.

The L3 algorithm and software were developed by Steven Lansel and Brian Wandell at Stanford University.  The code in this repository was initially drafted by SL, edited to work with ISET by SL and BW, and then extensivel developed by Haomiao Jiang, Qiyuan Tian, and Brian Wandell.

Copyright Steven Lansel, 2013
