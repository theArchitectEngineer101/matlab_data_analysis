% discreteConvAnim GENERATES AN ANIMATION OF THE DISCRETE CONVOLUTION PROCESS.
%   This function calculates the convolution between two discrete signals
%   and plots a step-by-step animation. The animation can be saved as a
%   high-quality MP4 video, animated GIFs of specific intervals, and PNG
%   snapshots of specific moments, all organized into a single output folder.
%
% SYNTAX:
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response)
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename)
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename, gif_intervals)
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename, gif_intervals, snap_points)
%
% INPUTS:
%       x_entry_signal     - A 1xN row vector for the input signal x[n].
%       h_impulse_response - A 1xM row vector for the impulse response h[n].
%       video_filename     - (Optional) String for the output MP4 filename. Use [] to skip.
%       gif_intervals      - (Optional) A Kx2 matrix defining time intervals [start, end]
%                            for GIF creation, where time is normalized from 0 to 1.
%       snap_points        - (Optional) A 1xP vector of normalized time points (0 to 1)
%                            at which to save a high-resolution PNG snapshot.
%
% OUTPUTS:
%       conv_vector        - A 1x(N+M-1) row vector with the convolution result.
%
% SEE ALSO:
%       conv, stem, stemPloter, videoRecorder, gifRecorder, snapshotRecorder, VideoWriter
%
% Author: theArchitectEngineer101
% Date: 20-Sep-2025
% Version: 7.0 - Centralized all media exports into a single folder.

function conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename, gif_intervals, snap_points)

    %% Configuration and Setup
    PADDING_SIZE           = 5;
    pause_before_inversion = 1.5;
    pause_before_shifting  = 1;
    pause_after_shifting   = 1;
    pause_iteration        = 0.3;
    pause_finale           = 1.5;

    % Handle optional arguments
    if nargin < 3, video_filename = []; end
    if nargin < 4, gif_intervals  = []; end
    if nargin < 5, snap_points    = []; end

    % Determine output folder name and create the directory if it doesn't exist
    if ~isempty(video_filename)
        [~, output_folder_name, ~] = fileparts(video_filename);
    else
        output_folder_name = 'exports';
    end
    if ~isfolder(output_folder_name)
        mkdir(output_folder_name);
    end

    % Video setup
    video_obj = [];
    generate_video = ~isempty(video_filename);
    if generate_video
        full_video_path = fullfile(output_folder_name, video_filename);
        v = VideoWriter(full_video_path, 'MPEG-4');
        v.FrameRate = 30;
        v.Quality   = 100;
        open(v);
        video_obj = v;
    end

    % Reset recorders
    gifRecorder('reset');
    snapshotRecorder('reset');

    %% Core Computations and Signal Preparation
    conv_vector = conv(x_entry_signal, h_impulse_response);
    x_dim       = length(x_entry_signal);
    h_dim       = length(h_impulse_response);
    h_inverted  = flip(h_impulse_response);

    % Zero-padding for full animation visibility
    if x_dim <= h_dim, shift_factor = h_dim + x_dim + PADDING_SIZE;
    else, shift_factor = x_dim + h_dim + PADDING_SIZE; end
    h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted          zeros(1, PADDING_SIZE + x_dim)];
    h_padded          = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response  zeros(1, PADDING_SIZE + x_dim)];
    x_padded          = [zeros(1, PADDING_SIZE + h_dim) x_entry_signal      zeros(1, PADDING_SIZE + h_dim)];

    % Create the discrete time axis 'n' for plotting
    n = -(h_dim+PADDING_SIZE) : x_dim + h_dim + PADDING_SIZE - 1;

    % Initialize animation vectors
    h_shifted   = circshift(h_inverted, shift_factor); % Initial position of h[n-i]
    convolution = zeros(1, length(n));
    mult_factor = zeros(1, length(n));

    %% Dynamic Range Calculation for Plots
    y_limit_sup_entry = max(x_padded);
    y_limit_inf_entry = min([0 x_padded]);
    y_limit_sup_resp  = max(h_impulse_response);
    y_limit_inf_resp  = min([0 h_impulse_response]);
    y_limit_sup_mult  = max(x_entry_signal)*max(h_impulse_response);
    y_limit_inf_mult  = min([0 min(x_entry_signal)*max(h_impulse_response) max(x_entry_signal)*min(h_impulse_response)]);
    y_limit_sup_conv  = max(conv_vector);
    y_limit_inf_conv  = min([0 conv_vector]);

    %% Time Calculation
    total_iterations = length(n) - h_dim;
    total_animation_time = pause_iteration * total_iterations + ...
                           pause_before_inversion + pause_before_shifting + ...
                           pause_after_shifting + pause_finale;
    elapsed_time = 0;

    %% Graphics Initialization
    % Create and configure the main figure window
    fig = figure;
    set(fig, 'Position', [100, 50, 720, 900]); % Set to vertical HD

    subplot(4,1,1)
    stemPloter(n, x_padded, y_limit_inf_entry, y_limit_sup_entry, 'Input Signal: x[n]', 'n', 'Amplitude', 'b');
    subplot(4,1,2);
    h_plot_handle    = stemPloter(n, h_padded, y_limit_inf_resp, y_limit_sup_resp, 'Impulse Response: h[n]', 'n', 'Amplitude', 'b');
    subplot(4,1,3);
    mult_plot_handle = stemPloter(n, mult_factor, y_limit_inf_mult, y_limit_sup_mult, 'Point-wise Product', 'n', 'Amplitude', 'm');
    subplot(4,1,4);
    conv_plot_handle = stemPloter(n, convolution, y_limit_inf_conv, y_limit_sup_conv, 'Convolution Result: y[n]', 'n', 'Amplitude', 'r');

    %% Nested Helper for Recording
    function framesRecorder(duration)
        videoRecorder(fig, video_obj, duration);
        
        current_progress_time = elapsed_time / total_animation_time;
        
        % GIF Recorder Logic
        gifs_to_record_this_frame = {};
        if ~isempty(gif_intervals)
            for i = 1:size(gif_intervals, 1)
                if current_progress_time >= gif_intervals(i, 1) && current_progress_time < gif_intervals(i, 2)
                    gif_base_name = 'animation_interval';
                    if generate_video, [~, name, ~] = fileparts(video_filename); gif_base_name = name; end
                    gif_name = sprintf('%s_%d', gif_base_name, i);
                    gifs_to_record_this_frame{end+1} = fullfile(output_folder_name, gif_name);
                end
            end
        end
        gifRecorder(fig, gifs_to_record_this_frame, duration);
        
        % Snapshot Recorder Logic
        snapshotRecorder(fig, video_filename, current_progress_time, snap_points, output_folder_name);
        
        elapsed_time = elapsed_time + duration;
    end  

    %% Initial Animation Steps (Before Loop)
    framesRecorder(pause_before_inversion);

    % Update h[n] to h[-n]
    set(h_plot_handle, 'YData', h_inverted);
    title(subplot(4,1,2), 'Flipped Response: h[-n]');
    framesRecorder(pause_before_shifting);

    % Update h[-n] to h[n-i] (initial position)
    set(h_plot_handle, 'YData', h_shifted);
    title(subplot(4,1,2), 'Shifted Response: h[n-i]');
    framesRecorder(pause_after_shifting);

    %% Animation loop
    for ii = 1:total_iterations
        % Update signal data
        h_shifted = circshift(h_shifted, 1);
        mult_factor = x_padded.*h_shifted;
        convolution(ii+h_dim) = sum(mult_factor);

        % Update plot data using handles
        set(h_plot_handle, 'YData', h_shifted);
        set(mult_plot_handle, 'YData', mult_factor);
        set(conv_plot_handle, 'YData', convolution);

        drawnow;
        framesRecorder(pause_iteration);
    end

    % Hold the final frame
    framesRecorder(pause_finale);

    %% Finalize Media
    if generate_video, close(video_obj); disp(['Video successfully saved: ' video_obj.Filename]); end
    if ~isempty(gif_intervals)
         for j = 1:size(gif_intervals, 1)
            gif_base_name = 'animation_interval';
            if generate_video, [~, name, ~] = fileparts(video_filename); gif_base_name = name; end
            gif_name = sprintf('%s_%d.gif', gif_base_name, j);
            full_gif_path = fullfile(output_folder_name, gif_name);
            disp(['GIF successfully saved:   ' full_gif_path]);
         end
    end
    
end