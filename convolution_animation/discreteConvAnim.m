% discreteConvAnim GENERATES AN ANIMATION OF THE DISCRETE CONVOLUTION PROCESS.
%   This function calculates the convolution between two discrete signals
%   and plots a step-by-step animation of the operation. The animation can
%   be displayed on screen or saved to a high-quality MP4 video file.
%
% SYNTAX:
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response)
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename)
%
% INPUTS:
%       x_entry_signal     - A 1xN row vector representing the discrete
%                            input signal x[n].
%       h_impulse_response - A 1xM row vector representing the discrete
%                            impulse response h[n].
%       video_filename     - (Optional) A string containing the desired
%                            output file name (e.g., 'animation.mp4'). If
%                            provided, the function saves the animation as
%                            a video file instead of pausing for on-screen
%                            viewing.
%
% OUTPUTS:
%       conv_vector        - A 1x(N+M-1) row vector containing the full
%                            result of the convolution y[n] = x[n] * h[n].
%
% EXAMPLE 1: On-screen Animation
%       % Define a rectangular input signal and an impulse response
%       x_signal = [1, 1, 1, 1];
%       h_response = [0.5, 1];
%       y = discreteConvAnim(x_signal, h_response);
%
% EXAMPLE 2: Save Animation to MP4
%       x_signal = [1, 1, 1, 1];
%       h_response = [0.5, 1];
%       y = discreteConvAnim(x_signal, h_response, 'rect_conv.mp4');
%
% SEE ALSO:
%       conv, stem, VideoWriter, getframe, circshift, drawnow
%
% Author: theArchitectEngineer101
% Date: 26-Aug-2025
% Version: 2.0

function conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename)

    %% Configuration and Setup
    % Check if video generation is requested
    generate_video = nargin > 2 && ~isempty(video_filename);

    % Animation and Padding Parameters
    PADDING_SIZE = 5;

    % On-screen animation pauses (in seconds)
    pause_before_inversion = 2;
    pause_before_shifting  = 1;
    pause_after_shifting   = 1;
    pause_iteration        = 0.9;
    pause_finale           = 2;

    % Video settings are initialized here if requested
    if generate_video
        v = VideoWriter(video_filename, 'MPEG-4');
        v.FrameRate = 30;   % Low FPS for clear, step-by-step viewing
        v.Quality   = 100; % Maximum quality for presentation
        open(v);
    end

    %% Core Computations and Signal Preparation
    % Perform the full convolution to get the final result vector
    conv_vector = conv(x_entry_signal, h_impulse_response);
    x_dim = length(x_entry_signal);
    h_dim = length(h_impulse_response);

    % Time-reverse the impulse response h[n] to get h[-n]
    h_inverted = flip(h_impulse_response);

    % Add zero-padding to signals for full animation visibility
    if x_dim <= h_dim
        h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted zeros(1, PADDING_SIZE + x_dim)];
        h_padded = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response zeros(1, PADDING_SIZE + x_dim)];
        shift_factor = h_dim + x_dim + PADDING_SIZE;
    else
        h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted zeros(1, PADDING_SIZE + x_dim)];
        h_padded = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response zeros(1, PADDING_SIZE + x_dim)];
        shift_factor = x_dim + h_dim + PADDING_SIZE;
    end
    x_entry_signal = [zeros(1, PADDING_SIZE+h_dim) x_entry_signal zeros(1, (PADDING_SIZE + h_dim))];

    % Create the discrete time axis 'n' for plotting
    n = -(h_dim+PADDING_SIZE) : x_dim + h_dim + PADDING_SIZE - 1;

    % Initialize animation vectors
    h_shifted   = circshift(h_inverted, shift_factor); % Initial position of h[n-k]
    convolution = zeros(1, length(n));

    %% Dynamic Range Calculation for Plots
    % Entry signal graph limits
    y_limit_sup_entry = max(x_entry_signal);
    y_limit_inf_entry = min([0 x_entry_signal]);

    % Impulse response graph limits
    y_limit_sup_resp = max(h_impulse_response);
    y_limit_inf_resp = min([0 h_impulse_response]);

    % Mult_factor graph limits
    y_limit_sup_mult = max(x_entry_signal)*max(h_impulse_response);
    y_limit_inf_mult = min([0 min(x_entry_signal)*max(h_impulse_response) max(x_entry_signal)*min(h_impulse_response)]);

    % Convolution graph limits
    y_limit_sup_conv = max(conv_vector);
    y_limit_inf_conv = min([0 conv_vector]);

    %% Static ploting
    % Create and configure the main figure window
    fig = figure;
    set(fig, 'Position', [100, 50, 720, 900]); % Set to vertical HD

    % Entry signal ploting
    subplot(4,1,1)
    stemPloter(n, x_entry_signal, y_limit_inf_entry, y_limit_sup_entry, 'Input Signal: x[n]', 'n', 'Amplitude', 'b')

    % Impulse response ploting
    subplot(4,1,2);
    stemPloter(n, h_padded, y_limit_inf_resp, y_limit_sup_resp, 'Impulse Response: h[n]', 'n', 'Amplitude', 'b')

    if generate_video
        num_frames_pause = pause_before_inversion * v.FrameRate;
        frame = getframe(fig);
        for i = 1:num_frames_pause
            writeVideo(v, frame);
        end
    else
        % Only pause if not generating video, to allow faster rendering
        pause(pause_before_inversion);
    end

    % Inverted impulse response ploting
    subplot(4,1,2);
    stemPloter(n, h_inverted, y_limit_inf_resp, y_limit_sup_resp, 'Flipped Response: h[-n]', 'n', 'Amplitude', 'b')

    if generate_video
        num_frames_pause = pause_before_shifting * v.FrameRate;
        frame = getframe(fig);
        for i = 1:num_frames_pause
            writeVideo(v, frame);
        end
    else
        % Only pause if not generating video, to allow faster rendering
        pause(pause_before_shifting);
    end

    % Shifted impulse response ploting
    subplot(4,1,2);
    stemPloter(n, h_shifted, y_limit_inf_resp, y_limit_sup_resp, 'Shifted Response: h[n-k]', 'n', 'Amplitude', 'b')

    if generate_video
        num_frames_pause = pause_after_shifting * v.FrameRate;
        frame = getframe(fig);
        for i = 1:num_frames_pause
            writeVideo(v, frame);
        end
    else
        % Only pause if not generating video, to allow faster rendering
        pause(pause_after_shifting);
    end

    total_iterations = length(n) - h_dim;
    snapshot_iteration = round(total_iterations / 2);

    %% Animation loop
    for ii = 1:total_iterations
        
        % Shifting inverted impulse response
        h_shifted = circshift(h_shifted, 1);

        % Multiplication factor calculation
        mult_factor = x_entry_signal.*h_shifted;

        % Convolution iterated calculation
        convolution(ii+h_dim) = sum(mult_factor);

        % Shifted impulse response ploting
        subplot(4,1,2);
        stemPloter(n, h_shifted, y_limit_inf_resp, y_limit_sup_resp, 'Shifted Response: h[n-k]', 'n', 'Amplitude', 'b')

        % Multiplication factor ploting
        subplot(4,1,3);
        stemPloter(n, mult_factor, y_limit_inf_mult, y_limit_sup_mult, 'Point-wise Product', 'n', 'Amplitude', 'm')

        % Convolution ploting
        subplot(4,1,4);
        stemPloter(n, convolution, y_limit_inf_conv, y_limit_sup_conv, 'Convolution Result: y[n]', 'n', 'Amplitude', 'r')

        drawnow;

        if ii == snapshot_iteration
            % Define the snapshot filename based on the video filename
            if generate_video
                [~, name, ~] = fileparts(video_filename);
                snapshot_filename = ['snapshot_' name '.png'];
            else
                snapshot_filename = 'snapshot_animation.png';
            end
            
            print(fig, snapshot_filename, '-dpng', '-r300'); % Save at 300 DPI
            disp(['High-resolution snapshot saved as: ' snapshot_filename]);
        end

        if generate_video
            frame = getframe(fig);
            for i = 1:6
                writeVideo(v, frame);
            end
        else
            % Only pause if not generating video, to allow faster rendering
            pause(pause_iteration);
        end
    end

    if generate_video
        num_frames_pause = pause_finale * v.FrameRate;
        frame = getframe(fig);
        for i = 1:num_frames_pause
            writeVideo(v, frame);
        end
    else
        % Only pause if not generating video, to allow faster rendering
        pause(pause_finale);
    end

    if generate_video
        close(v);
        disp(['Video successfully saved: ' video_filename]);
    end

end