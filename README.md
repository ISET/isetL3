L3 - Creating image processing pipelines for novel sensor designs
==

The code in the isetL3 repository implements  work described in this patent: [Learning of Image Processing Pipeline for Digital Imaging Devices](https://patents.google.com/patent/US20120307116) and this published paper
```
Learning the Image Processing Pipeline (2017). 
H. Jiang, Q. Tian, J. E. Farrell, B. Wandell
IEEE Transactions on Image Processing
Volume 10, pages 5032 - 5042
```

## Abstract
A learning technique is provided that learns how to process images by exploiting the spatial and spectral correlations inherent in image data to process and enhance images. Using a training set of input and desired output images, regression coefficients are learned that are optimal for a predefined estimation function that estimates the values at a pixel of the desired output image using a collection of similarly located pixels in the input image. Application of the learned regression coefficients is fast, robust to noise, adapts to the particulars of a dataset, and generalizes to a large variety of applications. The invention enables the use of image sensors with novel color filter array designs that offer expanded capabilities beyond existing sensors and take advantage of typical high pixel counts.

## Linear, Local, Learned (L3)
The isetL3 toolbox (Matlab) was created to automate the construction of an image processing pipeline for novel sensor arrays.  These arrays might contain novel CFAs, or sensors with different dynamic ranges.

The scripts here show how to perform the training and testing of the isetL3 (Local, Linear, Learned) algorithm for automatic generation of image processing pipelines for arbitrary CFA measurement schemes for digital imaging sensors. The isetL3 pipeline performs demosaicking, denoising, and the color transform in one step.  The algorithm allows output estimated images to be in any user specified color bands.

The isetL3 software here relies on the isetcam repository.

The tutorial scripts illustrating how to read, train and render are t_L3DataSimulation(); and t_L3DataISET;

For more instructions and references see this [temporary copy of the old wiki page](https://github.com/isetcam/isetL3/wiki/Scratch---from-old-pdc-wiki) and the [newer one under development](https://github.com/isetcam/isetL3/wiki).

## Referencing
The L3 algorithm and software were developed by Steven Lansel and Brian Wandell at Stanford University.  The code in this repository was initially drafted by SL, edited to work with ISET by SL and BW, and then extensively developed, extended and tested by Haomiao Jiang with help from Qiyuan Tian, Steve Lansel and Brian Wandell.  To reference this software, please use the patent and paper cited at the top.


