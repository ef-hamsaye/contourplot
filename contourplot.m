clc; clear; close all
load('arbitrary_dataset.mat')

%% Combine both datasets
x_combined = [x_1; x_2];
y_combined = [y_1; y_2];
A_combined = [A_1; A_2];
B_combined = [B_1; B_2];
x_boundaries_combined = [x_boundaries_1; x_boundaries_2];
y_boundaries_combined = [y_boundaries_1; y_boundaries_2];

%% Smoothing options
% Choose the filter and adjust its parameters
smoothing_options = {'Gaussian', 'Median', 'Mean', 'Bilateral', 'Savitzky-Golay'};
selected_filter = 'Gaussian';  % Choose the filter here (e.g., 'Gaussian', 'Median', 'Mean', 'Bilateral', 'Savitzky-Golay')
sigma_gaussian = 30;  % Adjust the sigma value for Gaussian filter
window_size_median = 5;  % Adjust the window size for Median filter
window_size_mean = 5;  % Adjust the window size for Mean filter
sigma_spatial_bilateral = 5;  % Adjust the spatial sigma value for Bilateral filter
sigma_intensity_bilateral = 0.1;  % Adjust the intensity sigma value for Bilateral filter
poly_order_savitzky = 3;  % Adjust the polynomial order for Savitzky-Golay filter
frame_size_savitzky = 21;  % Adjust the frame size for Savitzky-Golay filter

% Set the number of contour levels here
num_contours = 3;

%% Step 1: Remove duplicate (x_combined, y_combined) data points
[unique_x_combined, idx_combined] = unique(x_combined);
unique_y_combined = y_combined(idx_combined);
unique_A_combined = A_combined(idx_combined);
unique_B_combined = B_combined(idx_combined);

%% Step 2: Create a scatteredInterpolant object for interpolation and extrapolation
F_combined = scatteredInterpolant(unique_x_combined, unique_y_combined, unique_A_combined, 'natural', 'linear');
F1_combined = scatteredInterpolant(unique_x_combined, unique_y_combined, unique_B_combined, 'natural', 'linear');

%% Step 3: Define a finer grid for extrapolation
num_points = 5000; % Increase the number of points for better resolution
x_extrapolation_combined = linspace(min(x_boundaries_combined), max(x_boundaries_combined), num_points);
y_extrapolation_combined = linspace(min(y_boundaries_combined), max(y_boundaries_combined), num_points);
[X_extrapolation_combined, Y_extrapolation_combined] = meshgrid(x_extrapolation_combined, y_extrapolation_combined);

%% Step 4: Interpolate and extrapolate the A values on the fine grid
Z_extrapolation_combined = F_combined(X_extrapolation_combined, Y_extrapolation_combined);
Z1_extrapolation_combined = F1_combined(X_extrapolation_combined, Y_extrapolation_combined);

%% Step 5: Set values outside the custom shape boundaries to NaN
in_custom_shape_combined = inpolygon(X_extrapolation_combined, Y_extrapolation_combined, x_boundaries_combined, y_boundaries_combined);
Z_extrapolation_combined(~in_custom_shape_combined) = NaN;
Z1_extrapolation_combined(~in_custom_shape_combined) = NaN;

%% Step 6: Apply the selected filter for smoothing
switch selected_filter
    case 'Gaussian'
        Z_smoothed_combined = imgaussfilt(Z_extrapolation_combined, sigma_gaussian);
        Z1_smoothed_combined = imgaussfilt(Z1_extrapolation_combined, sigma_gaussian);
    case 'Median'
        Z_smoothed_combined = medfilt2(Z_extrapolation_combined, [window_size_median, window_size_median]);
        Z1_smoothed_combined = medfilt2(Z1_extrapolation_combined, [window_size_median, window_size_median]);
    case 'Mean'
        Z_smoothed_combined = imboxfilt(Z_extrapolation_combined, window_size_mean);
        Z1_smoothed_combined = imboxfilt(Z1_extrapolation_combined, window_size_mean);
    case 'Bilateral'
        Z_smoothed_combined = imbilatfilt(Z_extrapolation_combined, sigma_spatial_bilateral, sigma_intensity_bilateral);
        Z1_smoothed_combined = imbilatfilt(Z1_extrapolation_combined, sigma_spatial_bilateral, sigma_intensity_bilateral);
    case 'Savitzky-Golay'
        Z_smoothed_combined = sgolayfilt(Z_extrapolation_combined, poly_order_savitzky, frame_size_savitzky);
        Z1_smoothed_combined = sgolayfilt(Z1_extrapolation_combined, poly_order_savitzky, frame_size_savitzky);
    otherwise
        error('Invalid filter selection.');
end

%% Step 7: Clip the smoothed A values to the range of the original data
overall_min_A = min([min(A_1), min(A_2)]);
overall_max_A = max([max(A_1), max(A_2)]);

overall_min_B = min([min(B_1), min(B_2)]);
overall_max_B = max([max(B_1), max(B_2)]);

% Clip the smoothed A values
Z_smoothed_combined(Z_smoothed_combined < overall_min_A) = overall_min_A;
Z_smoothed_combined(Z_smoothed_combined > overall_max_A) = overall_max_A;

Z1_smoothed_combined(Z1_smoothed_combined < overall_min_B) = overall_min_B;
Z1_smoothed_combined(Z1_smoothed_combined > overall_max_B) = overall_max_B;

%% Step 8: Apply logarithmic transformation (optional)
use_log_transform = false;  % Set this to 'true' or 'false'

if use_log_transform == true
    Z_smoothed_combined = log10(Z_smoothed_combined);
    Z_smoothed_combined(isinf(Z_smoothed_combined)) = NaN; % Set infinite values to NaN
    
    Z1_smoothed_combined = log10(Z1_smoothed_combined);
    Z1_smoothed_combined(isinf(Z1_smoothed_combined)) = NaN; % Set infinite values to NaN
end

% Set the number of 'jet' colors here
num_colors = 256;

%% Step 9: Plot the A distribution on the custom shape using pcolor
figure(1);
if use_log_transform == true
    contour_range = logspace(log10(overall_min_A), log10(overall_max_A), num_contours);
    pcolor(X_extrapolation_combined, Y_extrapolation_combined, Z_smoothed_combined);
    caxis([log10(overall_min_A), log10(overall_max_A)]); % Set the color axis to match the log-scale
    colormap(jet(num_colors)); % Specify the number of 'jet' colors
    colorbar('Ticks', log10(contour_range), 'TickLabels', num2str(contour_range', '%.2f'));
%     title('Logarithmic Extrapolated A on Custom Shape');
else
    pcolor(X_extrapolation_combined, Y_extrapolation_combined, Z_smoothed_combined);
    caxis([overall_min_A, overall_max_A]); % Set the color axis for the original data range
    colormap(jet(num_colors)); % Specify the number of 'jet' colors
    colorbar;
%     title('Extrapolated A on Custom Shape');
end

shading interp;
colormap('jet'); % Change colormap as per your preference
xlabel('X-axis');
ylabel('Y-axis');

% Set appropriate axis limits to include the boundaries
xlim([min(x_boundaries_combined), max(x_boundaries_combined)]);
ylim([min(y_boundaries_combined), max(y_boundaries_combined)]);

% Make the aspect ratio equal to maintain the correct scale
axis equal;

hold on;
% plot(x_boundaries_1, y_boundaries_1, '--');
% hold on;
% plot(x_boundaries_2, y_boundaries_2, '--');

% Draw the contour lines with the specified contour levels
if use_log_transform == true
    contour(X_extrapolation_combined, Y_extrapolation_combined, Z_smoothed_combined, log10(contour_range), 'LineColor', 'none');
else
    contour(X_extrapolation_combined, Y_extrapolation_combined, Z_smoothed_combined, num_contours, 'LineColor', 'none');
end

% Adjust font and font size for the plot
set(gca, 'FontName', 'Times New Roman', 'FontSize', 16);

% Remove top and right axes
box off;

xlim([0 1200])
ylim([0 1200])

figure(2);
if use_log_transform == true
    contour_range = logspace(log10(overall_min_B), log10(overall_max_B), num_contours);
    pcolor(X_extrapolation_combined, Y_extrapolation_combined, Z1_smoothed_combined);
    caxis([log10(overall_min_B), log10(overall_max_B)]); % Set the color axis to match the log-scale
    colormap(jet(num_colors)); % Specify the number of 'jet' colors
    colorbar('Ticks', log10(contour_range), 'TickLabels', num2str(contour_range', '%.2f'));
%     title('Logarithmic Extrapolated B on Custom Shape');
else
    pcolor(X_extrapolation_combined, Y_extrapolation_combined, Z1_smoothed_combined);
    caxis([overall_min_B, overall_max_B]); % Set the color axis for the original data range
    colormap(jet(num_colors)); % Specify the number of 'jet' colors
    colorbar;
%     title('Extrapolated B on Custom Shape');
end

shading interp;
colormap('jet'); % Change colormap as per your preference
xlabel('X-axis');
ylabel('Y-axis');

% Set appropriate axis limits to include the boundaries
xlim([min(x_boundaries_combined), max(x_boundaries_combined)]);
ylim([min(y_boundaries_combined), max(y_boundaries_combined)]);

% Make the aspect ratio equal to maintain the correct scale
axis equal;

hold on;
% plot(x_boundaries_1, y_boundaries_1, '--');
% hold on;
% plot(x_boundaries_2, y_boundaries_2, '--');

% Draw the contour lines with the specified contour levels
if use_log_transform == true
    contour(X_extrapolation_combined, Y_extrapolation_combined, Z1_smoothed_combined, log10(contour_range), 'LineColor', 'none');
else
    contour(X_extrapolation_combined, Y_extrapolation_combined, Z1_smoothed_combined, num_contours, 'LineColor', 'none');
end

% Adjust font and font size for the plot
set(gca, 'FontName', 'Times New Roman', 'FontSize', 16);

% Remove top and right axes
box off;

xlim([0 1200])
ylim([0 1200])
