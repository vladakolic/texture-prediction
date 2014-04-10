function [row_match col_match error] = find_match(texture_sample, template, valid_mask, err_threshold, red_sample, green_sample, blue_sample, grey_sample)

global gauss_mask;
global window_size;

tot_weight = sum(sum(gauss_mask(valid_mask)));

% Valid mask keeps the gaussian mask values that we are going to use and
% discards the rest.
mask = valid_mask .* gauss_mask / tot_weight;
mask = mask(:)';

if size(template,3) == 3
    
    [pixels_in_window, num_neighborhoods] = size(red_sample);
    
    % Reshape the template colours so they can be compared to the sample
    % colours.
    red_vals = template(:,:,1);
    red_vals = red_vals(:);
    
    green_vals = template(:,:,2);
    green_vals = green_vals(:);
    
    blue_vals = template(:,:,3);
    blue_vals = blue_vals(:);
    
    % Duplicate the colour values so they have as many columns as the
    % sample colours.
    red_vals = repmat(red_vals, [1 num_neighborhoods]); 
    green_vals = repmat(green_vals, [1 num_neighborhoods]); 
    blue_vals = repmat(blue_vals, [1 num_neighborhoods]); 

    % Calculate the Gaussian-weighted sum of square distances between the
    % template colours and each column sample.   
    red_dist =  mask * (red_vals - red_sample).^2; 
    green_dist = mask * (green_vals - green_sample).^2; 
    blue_dist = mask * (blue_vals - blue_sample).^2; 

    % For coloured images we sum over the different colours
    SSD = (red_dist + green_dist + blue_dist); 
else
    [pixels_in_window, num_neighborhoods] = size(grey_sample);
    
    grey_vals = template(:,:);
    grey_vals = grey_vals(:);


    grey_vals = repmat(grey_vals, [1 num_neighborhoods]);
   
    grey_dist = mask * (grey_vals - grey_sample).^2;
    
    SSD = grey_dist;
end

% Remove the distances that are above the error threshold weighted by the
% best distance value, i.e. the best match. 
pixel_matches = find(SSD <= min(SSD) * (1+err_threshold));
% Randomly pick one of the results that are good enough.
pixel_match = pixel_matches(ceil(rand*length(pixel_matches)));

% Returns the difference in distance from the best match and the perfect
% match.
error = SSD(pixel_match);

% pixel_match is now an index in the image given by the column of the
% slided operation of the texture_image. It has size (size(texture_sample,1
% - window_size + 1)*size(texture_sample,2) - window_size + 1)). Thus we
% have to take this into account when converting back to row and column
% indicies.
[row_match col_match] = ind2sub(size(texture_sample) - window_size + 1, pixel_match);

% The given index is now the top-leftmost pixel in window_size. It needs to
% be shifted to the center to give us the pixel we want.
half_win = (window_size-1)/2;
row_match = row_match + half_win;
col_match = col_match + half_win;

end

