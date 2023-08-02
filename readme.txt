Overview
This MATLAB code allows researchers to visualize and analyze 2D data distribution on custom shapes. The code combines interpolation, extrapolation, and smoothing techniques to generate high-resolution heatmaps, providing valuable insights into the data, even in regions with no recorded data points. The following steps outline the process:

Prerequisites
Ensure that the 'arbitrary_dataset.mat' file containing the necessary data is loaded into the MATLAB workspace.

Step 1: Combine Data
The code combines two datasets representing variables A and B to create a unified dataset.

Step 2: Smoothing Options
Choose a smoothing filter from options such as 'Gaussian,' 'Median,' 'Mean,' 'Bilateral,' or 'Savitzky-Golay.' Adjust filter-specific parameters for optimal results.

Step 3: Remove Duplicate Data Points
Duplicate (x, y) data points are removed from the combined dataset.

Step 4: Create Interpolant Objects
ScatteredInterpolant objects are created for variables A and B, enabling accurate interpolation and extrapolation of data points.

Step 5: Define a Finer Grid
A finer grid is defined to improve the resolution of the heatmaps.

Step 6: Interpolate and Extrapolate Data
Data values are interpolated and extrapolated on the finer grid using the previously created ScatteredInterpolant objects.

Step 7: Set Values Outside Custom Shape to NaN
Data points outside the custom shape boundaries are set to NaN for better visualization.

Step 8: Apply Selected Smoothing Filter
The selected filter is applied to smooth the data.

Step 9: Clip Smoothed Data
Smoothed data is clipped to the range of the original data.

Step 10: Logarithmic Transformation (Optional)
An optional logarithmic transformation can be applied to the smoothed data.

Step 11: Plot Heatmaps
The code plots the heatmaps for variables A and B on the custom shape. Researchers can customize the colormap and contour levels for better visualization.

Note
This code is designed for researchers working with 2D data distributions on custom shapes. Make sure to adjust the parameters and options based on your specific dataset and research requirements.

For further details and implementation, refer to the comments provided in the MATLAB code. For any questions or assistance, please feel free to reach out to me at erfan.hamsayeh@ucalgary.ca. Also, I encourage my fellow researchers and program developers to enhance this code.

Using this code for research is allowed with proper citation (https://doi.org/10.5281/zenodo.8202684).



References
MATLAB Documentation
Assistance from ChatGPT