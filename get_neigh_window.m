function [template valid_mask] = get_neigh_window(image, visited, pix_row, pix_col)
% Returns the neighborhood window of size win_size around (pix_row,
% pix_col). Output is the pixel colour values of that window, and a valid
% mask, i.e. 

global window_size;


half_win = floor((window_size - 1) / 2);

if mod(window_size,2)
    % window size is odd
    win_row_range = pix_row - half_win : pix_row + half_win;
    win_col_range = pix_col - half_win : pix_col + half_win;
else
    % window size is even
    row_move = round(rand);
    win_row_range = pix_row - (half_win + row_move) : pix_row + (half_win + ~row_move);
    
    col_move = round(rand);
    win_col_range = pix_col - (half_win + col_move) : pix_col + (half_win + ~col_move); 
end

row_out_bounds = win_row_range < 1 | win_row_range > size(image,1);
col_out_bounds = win_col_range < 1 | win_col_range > size(image,2);

if sum(row_out_bounds) + sum(col_out_bounds) > 0
    row_in_bounds = win_row_range(~row_out_bounds);
    col_in_bounds = win_col_range(~col_out_bounds);
    
%     if size(image,3) == 3
        template = zeros(window_size, window_size, size(image,3));
        template(~row_out_bounds, ~col_out_bounds, :) = image(row_in_bounds, col_in_bounds, :);
%     else 
%         template = zeros(window_size, window_size);
%         template(~row_out_bounds, ~col_out_bounds) = image(row_in_bounds, col_in_bounds);
%     end
    
    valid_mask = false([window_size window_size]);
    valid_mask(~row_out_bounds, ~col_out_bounds) = visited(row_in_bounds, col_in_bounds);
else
    template = image(win_row_range, win_col_range, :);
    valid_mask = visited(win_row_range, win_col_range);
end

end

