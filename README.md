L3 - Creating image processing pipelines for novel sensor designs
==

Linear, Local, Learned

The L3 toolbox (Matlab) was created to automate the construction of an image processing pipeline for novel sensor arrays.  These arrays might contain novel CFAs, or sensors with different dynamic ranges.

The scripts here show how to perform the training and testing of the L3 (Local, Linear, Learned) algorithm for automatic generation of image processing pipelines for arbitrary CFA measurement schemes for digital imaging sensors. The L3 pipeline performs demosaicking, denoising, and the color transform in one step.  The algorithm allows output estimated images to be in any user specified color bands.

The L3 software here relies on the ISETCAM software.

The main scripts involved in using the L^3 algorithm are

	-s_L3TrainCamera:  Trains L^3 camera for a specific CFA using a set of 
	 multispectral scenes for training.

	-s_L3Render:  Applies the L^3 camera to a multispectral scene. 
	Result images are shown.

For more instructions and references see the Docs folder and http://white.stanford.edu/pdcwiki/index.php/L3_Algorithm

The scripts currently are written to run an example calculation for a 2x2 CFA containing red, green, blue, and white pixels.  The white pixel does not contain any filter and is much more sensitive to light, which allows imaging in low light.  Sample data containing images of faces is included to perform the calculation.

The following describes the contents of some of the folders of interest:

	-Data:  Contains some data files that can be used such as illuminants,
	 sensors, and reflectance images.  Any data can be used that is on the 
	 Matlab path but data should have the same format as these files.  

	-Results:  Learned L^3 pipeline files and estimated images will 
     	 automatically be saved in this folder.

	-Scripts to Show Results:  Contains a few scripts to display the 
     	 original and estimated images, the derived filters, etc.

The L3 algorithm and software were developed by Steven Lansel and Brian Wandell at Stanford University.  The code in this repository was initially drafted by SL, then edited to work with ISET by SL and BW, and then further developed by Qiyuan Tian and Haomiao Jiang.

Copyright Steven Lansel, 2013
