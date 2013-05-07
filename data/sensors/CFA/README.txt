A CFA file contains a description of the filter sensitivities and arrangement.  This does not include the additional parameters required to simulate the sensor.



All CFA data files should contain the following variables:
   comment:     String containing some description of the file
   data:        Matrix containing sensitivities of the filters
                (size(data)=length(wavelength) x number of filters)
   filterNames: Cell array containing strings giving names of each of the filters (in order)
		(size(filterNames)=1 x number of filters)
   filterOrder: Matrix giving the spatial pattern of the filters, each entry in this matrix 		is a number between 1 and the number of filters
   units:       String describing the units (presumably 'photons')
   wavelength:  Vector giving the samples of the wavelength (in nm)
                (size(wavelength)=1 x number of samples)



Following are CFA files in this folder:

      Filename                 	source          wavelength
   cfaNikonD100RedIR      	???             380:4:1068
   cfaNikonD100RIR      	???             380:4:1068
   cfaNikonD200IR   	   	???             380:4:1068
   NikonD1			???		380:4:780   (missing some fields)
   NikonD70			???		380:4:780   (missing some fields)
   NikonD100			???		380:1:1068





The sensitivities can be interpolated from their wavelength to the sampling given by the vector 'wave' using the following code:

tmp=load('cfaData');
data=interp1(tmp.wavelength,tmp.data,wave);