% snapshotRecorder Saves a high-resolution PNG snapshot of a figure at specific time points.
%   This function checks the current progress of an animation and saves a
%   snapshot if the progress crosses a specified threshold. It manages its
%   own state to ensure each snapshot is taken only once per animation run.
%
%   SYNTAX:
%       snapshotRecorder(fig_handle, base_filename, current_progress, snap_points, output_folder)
%       snapshotRecorder('reset')
%
%   INPUTS:
%       fig_handle        - The handle to the figure to be captured, or the
%                           string 'reset' to clear the persistent state.
%       base_filename     - A string used as the base for the output PNG filename.
%                           Can be empty.
%       current_progress  - A scalar from 0 to 1 indicating the current
%                           normalized time in the animation.
%       snap_points       - A vector of normalized time points (0 to 1) at
%                           which to save snapshots.
%       output_folder     - (Optional) String with the path to the folder where
%                           snapshots will be saved.

function snapshotRecorder(fig_handle, base_filename, current_progress, snap_points, output_folder)
    
    persistent snaps_taken;

    % Handle optional argument for the output folder
    if nargin < 5, output_folder = ''; end % Default to current directory if not provided

    % Handle reset call to clear the state for a new animation
    if ischar(fig_handle) && strcmp(fig_handle, 'reset')
        snaps_taken = [];
        return;
    end
    
    % If no snapshot points are provided, do nothing.
    if isempty(snap_points)
        return;
    end
    
    % Initialize the state tracker on the first actual call for a new animation
    if isempty(snaps_taken)
        snaps_taken = false(1, length(snap_points));
    end

    % Loop through each specified snapshot point
    for k = 1:length(snap_points)
        % Check if this snapshot point has been reached and not yet taken
        if ~snaps_taken(k) && current_progress >= snap_points(k)
            
            % Determine the base name for the snapshot file
            snap_base_name = 'snapshot';
            if ~isempty(base_filename)
                [~, name, ~] = fileparts(base_filename);
                snap_base_name = name;
            end
            
            % Construct the filename and then the full path
            snap_filename_only = sprintf('%s_snap_%d_pct.png', snap_base_name, round(snap_points(k)*100));
            snap_full_path = fullfile(output_folder, snap_filename_only);
            
            % Save the current figure as a high-resolution PNG
            exportgraphics(fig_handle, snap_full_path, 'Resolution', 300);
            disp(['PNG successfully saved: ' snap_full_path]);
            
            % Mark this snapshot as taken to prevent duplicates
            snaps_taken(k) = true;
        end
    end
end
