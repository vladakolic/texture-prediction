function [pixel_rows pixel_cols] = get_blank_neighbors(visited)
% Given a matrix of visited pixels, returns the list of
% unvisited pixels that have sorted pixels as their neighbors. List is
% randomized then sorted according to number of known neighbors.
    global window_size

    % Expands the border of visited by one in every direction.
    expanded_visited = bwmorph(visited, 'dilate');
    % Removes visited from the expanded_visited, leaving only the border.
    unfilled_pixels = expanded_visited - visited;
    
    % Returns the indices of the border pixels
    [pixel_rows pixel_cols] = find(unfilled_pixels);
   
    % Randomly order the pixel inicies
    rand_index = randperm(length(pixel_rows));
    pixel_rows = pixel_rows(rand_index);
    pixel_cols = pixel_cols(rand_index);
   
    % Returns the number of known neighbors within window_size
    neigh_sums = colfilt(visited, [window_size window_size], 'sliding', @sum);
    
    % Convert row and column index to linear index.
    linear_index = sub2ind(size(neigh_sums), pixel_rows, pixel_cols);
    % Return the indexes of the linear index, according to most amount of
    % neighbors.
    [~, idx] = sort(neigh_sums(linear_index), 'descend');
    % Return the index given by the linear index (thus can access the
    % visited matrix).
    sorted = linear_index(idx);
    
    % Convert linear indexes to row and column index
    [pixel_rows pixel_cols] = ind2sub(size(visited), sorted);
    
end