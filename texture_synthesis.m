%function f = texture_synthesis(image, window_size, texture_image_size)
clf;

global gauss_mask;
global window_size;

image = 'texture4.jpg';
window_size=9;

% Read texture sample
texture_sample = im2double(imread(image));
[num_rows, num_columns, num_colours] = size(texture_sample);
texture_image_size=num_rows*2;

% Initialize constants
sigma = window_size/6.4;
err_threshold = 0.1;
max_err_threshold = 0.3;
gauss_mask = fspecial('gaussian',window_size, sigma);



if num_colours == 3
    % For coloured images, matches are found by adding the mean square
    % distance of each colour. Save each sliding colour window from the
    % texture_sample to avoid doing it every iteration.
    red_sample = im2col(texture_sample(:,:,1), [window_size window_size]);
    green_sample = im2col(texture_sample(:,:,2), [window_size window_size]);
    blue_sample = im2col(texture_sample(:,:,3), [window_size window_size]);

    grey_sample = [];
else
    % For grey-scale images, matches are found by adding the mean square
    % distance of the grey-scale.
    grey_sample = im2col(texture_sample(:,:), [window_size window_size]);
    red_sample = []; green_sample = []; blue_sample = [];
end

% Initialize texture image (where result will be written onto)
texture = zeros(texture_image_size, texture_image_size, num_colours);
texture(1:num_rows, 1:num_columns,:) = texture_sample;

% Initialize visited matrix to keep track of pixels that have been written
% onto. Written pixels are set to true, non-written are false.
visited = false([texture_image_size texture_image_size]);
visited(1:num_rows, 1:num_columns) = true([num_rows num_columns]);

% Initialize stopping conditions
num_pixels = texture_image_size^2;
num_filled = size(texture_sample,1)*size(texture_sample,2);

% Whilst image is not filled ...
while num_filled < num_pixels
    progress = 0;
    
    % Get a list of unvisited pixels that are next to the visited pixels.
    [pixel_rows pixel_columns] = get_blank_neighbors(visited);

    % For each neighbor ...
    for i = [pixel_rows pixel_columns]';
        
        % Get the neighborhood window and valid mask around the neighbor i.
        [template valid_mask] = get_neigh_window(texture, visited, i(1), i(2));
        
        % Generate a pixel match and its difference (error) from the ideal
        % value.3
        [row_match col_match best_match_error] = find_match(texture_sample, template, valid_mask, err_threshold, red_sample, green_sample, blue_sample, grey_sample);
        
        % If match is good enough...
        if best_match_error < max_err_threshold   
            
           % Set the neighbor pixel to that value.
           texture(i(1),i(2),:) = texture_sample(row_match, col_match, :);
           % Set visited to true.
           visited(i(1), i(2)) = true;
           % One step closer to goal !
           num_filled = num_filled + 1;
           progress = 1;
        end
    end
    
    % Display the updated image for the pleasure of the viewer.
    imshow(texture);
    drawnow
    
    if progress==0
        max_err_threshold = max_err_threshold * 1.1;  
        disp(sprintf('Max error threshold increased to %d', max_err_threshold))
    end
   
end

imshow(texture)
imwrite(texture, strcat(int2str(window_size), 'x', int2str(window_size), '_complete_', image), 'jpg')

%end