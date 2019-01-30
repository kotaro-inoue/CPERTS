# Convolution-PERTS
The reseach based on [PERT (Pixel of the Elemental image Rearrangement Technique)](https://www.osapublishing.org/jdt/abstract.cfm?uri=jdt-5-2-61) and [PERTS (PERT considering the empty Space)](http://iopscience.iop.org/article/10.1088/2040-8986/aaa391/meta).  
It is my latest reconstruction algorithm in integral imaging, and it improved the speed of PERTS.  
In addition, you can apply the diffraction pattern of the aperture of lenslet.

# Usage
Please run /src/CPERTS.m.  
You can compare the resolution between VCR(Volumetric computational reconstruction) using ISO12233 resolution chart.

# Appendix
|Comparison of resolution|
|:-:|
|![vcr](https://kotaro-inoue.gitlab.io/img/PERTS/horizontal_vcr.png)|
|VCR|
|![perts](https://kotaro-inoue.gitlab.io/img/PERTS/horizontal_perts.png)|
|PERTS|
|![cperts](https://kotaro-inoue.gitlab.io/img/PERTS/horizontal_cperts.png)|
|CPERTS|
