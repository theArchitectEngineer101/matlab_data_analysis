% gifRecorder Captures a frame and appends it to one or more GIF files.
%   This function grabs the content of a figure and writes it to a GIF
%   file. It can manage the state of multiple GIF files simultaneously,
%   handling the creation of each file on the first call and appending
%   frames on subsequent calls. This version is optimized to capture and
%   process the frame only once per call, even for multiple files.
%
%   SYNTAX:
%       gifRecorder(fig_handle, gif_filenames, frame_delay)
%       gifRecorder('reset')
%
%   INPUTS:
%       fig_handle        - The handle to the figure to be captured, or the
%                           string 'reset' to clear the persistent state.
%       gif_filenames     - A cell array of strings, where each string is a
%                           filename for a GIF to be recorded in this frame.
%       frame_delay       - The time in seconds to delay before displaying
%                           the next frame.

function gifRecorder(fig_handle, gif_filenames, frame_delay)
    
    persistent file_states;

    % Handle reset call to clear the state of all recorded GIFs
    if ischar(fig_handle) && strcmp(fig_handle, 'reset')
        file_states = struct(); % Reset to an empty struct
        return;
    end
    
    % Initialize the state tracker on the very first run
    if isempty(file_states)
        file_states = struct();
    end

    % If no filenames are provided for this frame, do nothing.
    if isempty(gif_filenames)
        return;
    end
    
    % Capture and process the frame data ONCE for all GIFs in this call.
    frame = getframe(fig_handle);
    img = frame2im(frame);
    [indexed_img, color_map] = rgb2ind(img, 256);

    % Loop through each filename passed in the cell array
    for i = 1:length(gif_filenames)
        gif_filename = gif_filenames{i};

        % Ensure the filename has a .gif extension for proper file association.
        [path, name, ext] = fileparts(gif_filename);
        if ~strcmpi(ext, '.gif')
            gif_filename = fullfile(path, [name, '.gif']);
        end
    
        % Create a valid field name from the filename to use as a key in the struct
        safe_fieldname = matlab.lang.makeValidName(gif_filename);
    
        % Check if this is the first frame for THIS specific GIF file
        if ~isfield(file_states, safe_fieldname)
            is_first_frame_for_this_file = true;
        else
            is_first_frame_for_this_file = false;
        end
        
        % Use the pre-processed image data to write to the file
        if is_first_frame_for_this_file
            % Create the new GIF file and register it in our state struct
            imwrite(indexed_img, color_map, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', frame_delay);
            file_states.(safe_fieldname) = true; % Mark this file as created
        else
            % Append to the existing GIF file
            imwrite(indexed_img, color_map, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', frame_delay);
        end
    end
end
