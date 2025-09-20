% discreteConvAnim GENERATES AN ANIMATION OF THE DISCRETE CONVOLUTION PROCESS.
%   This function calculates the convolution between two discrete signals
%   and plots a step-by-step animation. The animation can be saved as a
%   high-quality MP4 video and/or an animated GIF.
%
% SYNTAX:
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response)
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename)
%       conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename, gif_filename)
%
% INPUTS:
%       x_entry_signal     - A 1xN row vector for the input signal x[n].
%       h_impulse_response - A 1xM row vector for the impulse response h[n].
%       video_filename     - (Optional) String for the output MP4 filename. Use [] to skip.
%       gif_filename       - (Optional) String for the output GIF filename.
%
% OUTPUTS:
%       conv_vector        - A 1x(N+M-1) row vector with the convolution result.
%
% SEE ALSO:
%       conv, stem, stemPloter, videoRecorder, gifRecorder, VideoWriter
%
% Author: theArchitectEngineer101
% Date: 20-Sep-2025
% Version: 4.0 - Implemented GIF generation.

function conv_vector = discreteConvAnim(x_entry_signal, h_impulse_response, video_filename, gif_filename)

    %% Configuration and Setup
    % Animation and Padding Parameters
    PADDING_SIZE           = 5;
    % On-screen animation pauses (in seconds)
    pause_before_inversion = 2;
    pause_before_shifting  = 1;
    pause_after_shifting   = 1;
    pause_iteration        = 0.3;
    pause_finale           = 2;

    % Handle optional arguments to prevent errors
    if nargin < 3, video_filename = []; end
    if nargin < 4, gif_filename = []; end

    % Video settings
    video_obj = [];
    generate_video = ~isempty(video_filename);
    if generate_video
        v = VideoWriter(video_filename, 'MPEG-4');
        v.FrameRate = 30;
        v.Quality   = 100;
        open(v);
        video_obj = v;
    end

    % Reset GIF recorder state for new animations
    gifRecorder('reset');

    %% Core Computations and Signal Preparation
    conv_vector = conv(x_entry_signal, h_impulse_response);
    x_dim = length(x_entry_signal);
    h_dim = length(h_impulse_response);
    h_inverted = flip(h_impulse_response);

    % Zero-padding for full animation visibility
    if x_dim <= h_dim
        h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted zeros(1, PADDING_SIZE + x_dim)];
        h_padded = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response zeros(1, PADDING_SIZE + x_dim)];
        shift_factor = h_dim + x_dim + PADDING_SIZE;
    else
        h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted zeros(1, PADDING_SIZE + x_dim)];
        h_padded = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response zeros(1, PADDING_SIZE + x_dim)];
        shift_factor = x_dim + h_dim + PADDING_SIZE;
    end
    x_padded = [zeros(1, PADDING_SIZE+h_dim) x_entry_signal zeros(1, (PADDING_SIZE + h_dim))];

    % Create the discrete time axis 'n' for plotting
    n = -(h_dim+PADDING_SIZE) : x_dim + h_dim + PADDING_SIZE - 1;

    % Initialize animation vectors
    h_shifted   = circshift(h_inverted, shift_factor); % Initial position of h[n-k]
    convolution = zeros(1, length(n));
    mult_factor = zeros(1, length(n));

    %% Dynamic Range Calculation for Plots
    y_limit_sup_entry = max(x_padded);
    y_limit_inf_entry = min([0 x_padded]);
    y_limit_sup_resp = max(h_impulse_response);
    y_limit_inf_resp = min([0 h_impulse_response]);
    y_limit_sup_mult = max(x_entry_signal)*max(h_impulse_response);
    y_limit_inf_mult = min([0 min(x_entry_signal)*max(h_impulse_response) max(x_entry_signal)*min(h_impulse_response)]);
    y_limit_sup_conv = max(conv_vector);
    y_limit_inf_conv = min([0 conv_vector]);

    %% Graphics Initialization
    % Create and configure the main figure window
    fig = figure;
    set(fig, 'Position', [100, 50, 720, 900]); % Set to vertical HD

    % Entry signal ploting
    subplot(4,1,1)
    stemPloter(n, x_padded, y_limit_inf_entry, y_limit_sup_entry, 'Input Signal: x[n]', 'n', 'Amplitude', 'b');

    % Initialize Animated Plots and Get Handles
    subplot(4,1,2);
    h_plot_handle = stemPloter(n, h_padded, y_limit_inf_resp, y_limit_sup_resp, 'Impulse Response: h[n]', 'n', 'Amplitude', 'b');
    subplot(4,1,3);
    mult_plot_handle = stemPloter(n, mult_factor, y_limit_inf_mult, y_limit_sup_mult, 'Point-wise Product', 'n', 'Amplitude', 'm');
    subplot(4,1,4);
    conv_plot_handle = stemPloter(n, convolution, y_limit_inf_conv, y_limit_sup_conv, 'Convolution Result: y[n]', 'n', 'Amplitude', 'r');

    %% Initial Animation Steps (Before Loop)
    videoRecorder(fig, video_obj, pause_before_inversion);
    gifRecorder(fig, gif_filename, pause_before_inversion);

    % Update h[n] to h[-n]
    set(h_plot_handle, 'YData', h_inverted);
    title(subplot(4,1,2), 'Flipped Response: h[-n]');
    videoRecorder(fig, video_obj, pause_before_shifting);
    gifRecorder(fig, gif_filename, pause_before_shifting);

    % Update h[-n] to h[n-k] (initial position)
    set(h_plot_handle, 'YData', h_shifted);
    title(subplot(4,1,2), 'Shifted Response: h[n-k]');
    videoRecorder(fig, video_obj, pause_after_shifting);
    gifRecorder(fig, gif_filename, pause_after_shifting);

    total_iterations = length(n) - h_dim;

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

        % Record frame or pause
        videoRecorder(fig, video_obj, pause_iteration);
        gifRecorder(fig, gif_filename, pause_iteration);
    end

    % Hold the final frame
    videoRecorder(fig, video_obj, pause_finale);
    gifRecorder(fig, gif_filename, pause_finale);

    % Finalize video if generated
    if generate_video
        close(video_obj);
        disp(['Video successfully saved: ' video_filename]);
    end
    if ~isempty(gif_filename)
        disp(['GIF successfully saved: ' gif_filename]);
    end

end