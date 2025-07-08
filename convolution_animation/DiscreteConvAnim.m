function conv_vector = DiscreteConvAnim(x_entry_signal, h_impulse_response)
%DISCRETE_CONV_ANIM Generates an animation of the discrete convolution process.
%   This function calculates the convolution between two discrete signals
%   and plots a step-by-step, frame-by-frame animation showing the sliding 
%   of the flipped impulse response, the multiplication, and the summation 
%   that constitute the convolution operation.
%
%   Syntax:
%       y = discrete_conv_anim(x, h)
%
%   Inputs:
%       x_entry_signal     - A 1xN row vector representing the discrete 
%                            input signal x[n].
%       h_impulse_response - A 1xM row vector representing the discrete 
%                            impulse response h[n].
%
%   Outputs:
%       conv_vector        - A 1x(N+M-1) row vector containing the full 
%                            result of the convolution y[n] = x[n] * h[n].
%
%   Example Usage:
%       % Define a rectangular input signal and an impulse response
%       input_x = [1, 1, 1, 1, 1];
%       response_h = [0.5, 0.5];
%
%       % Generate the animation and store the result
%       output_y = discrete_conv_anim(input_x, response_h);
%
%   See also: conv, stem, plot, circshift, drawnow
%
%   Author: theArchitectEngineer101
%   Date: 03-Jul-2025

conv_vector = conv(x_entry_signal, h_impulse_response);
x_dim = length(x_entry_signal); h_dim = length(h_impulse_response);

%% Calculating graph limits
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

%% Vectors treatment and resizing
PADDING_SIZE = 5;
% Time reversed impulse response
h_inverted = flip(h_impulse_response);

if x_dim <= h_dim
    h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted zeros(1, PADDING_SIZE + x_dim)];
    h_padded = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response zeros(1, PADDING_SIZE + x_dim)];
    shift_factor = h_dim + x_dim + PADDING_SIZE;
else
    h_inverted = [zeros(1, PADDING_SIZE + h_dim) h_inverted zeros(1, PADDING_SIZE + x_dim)];
    h_padded = [zeros(1, PADDING_SIZE + h_dim) h_impulse_response zeros(1, PADDING_SIZE + x_dim)];
    shift_factor = x_dim + h_dim + PADDING_SIZE;
end

% Entry signal treatment
x_entry_signal = [zeros(1, PADDING_SIZE+h_dim) x_entry_signal zeros(1, (PADDING_SIZE + h_dim))];

h_shifted = circshift(h_inverted, shift_factor);

n = -(h_dim+PADDING_SIZE) :1: x_dim + h_dim + PADDING_SIZE - 1;

%% Static ploting
% Entry signal ploting
subplot(4,1,1)
stem(n, x_entry_signal, 'b', 'LineWidth', 2);
xlim([min(n) max(n)])
ylim([y_limit_inf_entry, y_limit_sup_entry])
grid on;
title('x[n]');
xlabel('n', 'Interpreter', 'latex');
ylabel('Amplitude', 'Interpreter', 'latex')

% Impulse response ploting
subplot(4,1,2);
stem(n, h_padded,'b', 'LineWidth', 2);
xlim([min(n) max(n)])
ylim([y_limit_inf_resp, y_limit_sup_resp]);
grid on;
title('h[n]');
xlabel('n', 'Interpreter', 'latex');
ylabel('Amplitude', 'Interpreter', 'latex');

pause(4)

% Inverted impulse response ploting
subplot(4,1,2);
stem(n, h_inverted,'b', 'LineWidth', 2);
xlim([min(n) max(n)])
ylim([y_limit_inf_resp, y_limit_sup_resp]);
grid on;
title('h[n]');
xlabel('n', 'Interpreter', 'latex');
ylabel('Amplitude', 'Interpreter', 'latex');

pause(2)

% Shifted impulse response ploting
subplot(4,1,2);
stem(n, h_shifted,'b', 'LineWidth', 2);
xlim([min(n) max(n)])
ylim([y_limit_inf_resp, y_limit_sup_resp]);
grid on;
title('h[n]');
xlabel('n', 'Interpreter', 'latex');
ylabel('Amplitude', 'Interpreter', 'latex');

pause(1)

convolution = zeros(1, length(n));

%% Animation loop
for ii = 1:length(n)-h_dim

    % Shifting inverted impulse response
    h_shifted = circshift(h_shifted, 1);

    % Multiplication factor calculation
    mult_factor = x_entry_signal.*h_shifted;

    % Convolution iterated calculation
    convolution(ii+h_dim) = sum(mult_factor);

    % Shifted impulse response ploting
    subplot(4,1,2);
    stem(n, h_shifted,'b', 'LineWidth', 2);
    xlim([min(n) max(n)])
    ylim([y_limit_inf_resp, y_limit_sup_resp]);
    grid on;
    title('h[n]');
    xlabel('n', 'Interpreter', 'latex');
    ylabel('Amplitude', 'Interpreter', 'latex');

    % Multiplication factor ploting
    subplot(4,1,3);
    stem(n, mult_factor, 'b', 'LineWidth', 2);
    xlim([min(n) max(n)])
    ylim([y_limit_inf_mult, y_limit_sup_mult]);
    grid on;
    title('Fator da Soma de Convolução');
    xlabel('n', 'Interpreter', 'latex');
    ylabel('Amplitude', 'Interpreter', 'latex');

    % Convolution ploting
    subplot(4,1,4);
    stem(n, convolution, 'b', 'LineWidth', 2);
    xlim([min(n) max(n)])
    ylim([y_limit_inf_conv,y_limit_sup_conv]);
    grid on;
    title('y[n]');
    xlabel('n', 'Interpreter', 'latex');
    ylabel('Amplitude', 'Interpreter', 'latex');

    pause(0.8);
    drawnow;

end