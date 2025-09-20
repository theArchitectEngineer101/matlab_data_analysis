% gifRecorder Captures a frame and appends it to a GIF file.
%   This function grabs the content of a figure and writes it to a GIF
%   file. It handles the creation of the file on the first call and appends
%   frames on subsequent calls. The function does nothing if gif_filename
%   is empty. It can also be called with 'reset' to prepare for a new GIF.
%
%   SYNTAX:
%       gifRecorder(fig_handle, gif_filename, frame_delay)
%       gifRecorder('reset')
%
%   INPUTS:
%       fig_handle        - The handle to the figure to be captured, or the
%                           string 'reset' to clear the persistent state.
%       gif_filename      - String containing the name of the output GIF file.
%                           If empty, the function returns immediately.
%       frame_delay       - The time in seconds to delay before displaying
%                           the next frame.

function gifRecorder(fig_handle, gif_filename, frame_delay)
    
    persistent is_first_frame;

    % Handle reset call to allow for multiple GIF generations in one session
    if ischar(fig_handle) && strcmp(fig_handle, 'reset')
        is_first_frame = []; % Reset the state
        return;
    end

    % If no filename is provided, do nothing. This encapsulates the logic.
    if isempty(gif_filename)
        return;
    end
    
    % Initialize the persistent variable on the first actual write call.
    if isempty(is_first_frame)
        is_first_frame = true;
    end

    % Ensure the filename has a .gif extension for proper file association.
    [~, ~, ext] = fileparts(gif_filename);
    if ~strcmpi(ext, '.gif')
        gif_filename = [gif_filename, '.gif'];
    end

    frame = getframe(fig_handle);
    img = frame2im(frame);
    [indexed_img, color_map] = rgb2ind(img, 256);
    
    if is_first_frame
        imwrite(indexed_img, color_map, gif_filename, 'GIF', 'Loopcount', inf, 'DelayTime', frame_delay);
        is_first_frame = false;
    else
        imwrite(indexed_img, color_map, gif_filename, 'GIF', 'WriteMode', 'append', 'DelayTime', frame_delay);
    end
end

