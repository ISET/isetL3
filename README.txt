L3
====================================

Linear, Local, Learned


We are starting to keep the documentation on the wiki page at:

http://white.stanford.edu/pdcwiki/index.php/L3_Algorithm

Below are original notes that Steve wrote some time ago.

  Dec. 2011, BW

The L^3 pipeline Matlab toolbox performs the training and testing of the 
L^3 (Local, Linear, Learned) algorithm for automatic generation of image 
processing pipelines for arbitrary CFA measurement schemes for digital 
imaging sensors.  The L^3 pipeline implemented here performs demosaicking, 
denoising, and the color transform in one step.  The L^3 algorithm allows 
output estimated images to be in any user specified color bands.


The main scripts involved in using the L^3 algorithm are:
	-L3multispectral2images:  Converts multispectral scenes to noise-free 
     images sampled in the same way as the sensor.  The images are fully 
     sampled and contain channels  for both the input and output color 
     spaces.
	-L3trainlookup:  Trains the L^3 pipeline over a set of training 
     images and algorithm parameters.
	-L3wrapperimage:  Completes the camera simulation by subsampling and 
     adding noise then applying the L^3 pipeline to generate the image 
     estimate.  An alternative basic pipeline is also applied and a few 
     quality metrics are calculated for the resultant images.

Refer to code_overview.ppt for a more detailed description of the scripts.
Most users of the software will need to edit and run only these scripts.

The scripts currently are written to run an example calculation for a 2x2 
CFA containing red, green, blue, and white pixels.  The white pixel does 
not contain any filter and is much more sensitive to late, which allows an 
increased dynamic range.  Sample data containing images of faces is 
included to perform the calculation.

The following describes the contents of some of the folders of interest:
	-Data:  Contains some data files that can be used such as illuminants,
	 sensors, and reflectance images.  Any data can be used that is on the 
     Matlab path but data should have the same format as these files.  
     Images from L3multispectral2images.m will be saved here.
	-Results:  Learned L^3 pipeline files and estimated images will 
     automatically be saved in this folder.
	-Scripts to Show Results:  Contains a few scripts to display the 
     original and estimated images, the derived filters, etc.


The L^3 algorithm and software were developed by Steven Lansel while in the
Wandell Lab at Stanford University.

Copyright Steven Lansel, 2011