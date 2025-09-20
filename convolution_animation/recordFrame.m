%RECORDFRAME Captures a frame for animation or pauses execution.
%   This helper function decides whether to write a frame to a video object
%   or to pause the MATLAB execution based on whether a video object is
%   provided.
%
%   SYNTAX:
%       recordFrame(fig_handle, video_obj, duration_sec)
%
%   INPUTS:
%       fig_handle   - The handle to the figure to be captured.
%       video_obj    - A VideoWriter object. If this is empty ([]), the
%                      function will pause instead of recording.
%       duration_sec - The duration in seconds for the pause or for how
%                      long the frame should be held in the video.

function recordFrame(fig_handle, video_obj, duration_sec)

    % Check if a valid VideoWriter object was provided
    if ~isempty(video_obj)
        % Video Generation Logic
        % Calculate the number of frames to write to simulate a pause
        num_frames_to_write = round(duration_sec * video_obj.FrameRate);
        
        % Ensure at least one frame is written for very short durations
        if num_frames_to_write == 0 && duration_sec > 0
            num_frames_to_write = 1;
        end
        
        frame = getframe(fig_handle);
        for i = 1:num_frames_to_write
            writeVideo(video_obj, frame);
        end
    else
        % On-screen Animation Logic
        % If no video object, just pause the execution
        pause(duration_sec);
    end
end
