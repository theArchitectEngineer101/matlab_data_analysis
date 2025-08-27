% stemPloter A helper function to create and format a customized stem plot.
%
% SYNTAX:
%   stemPloter(x, y, y_lim_inf, y_lim_sup, plot_title, x_label, y_label, color)
%
% INPUTS:
%   x          - Horizontal axis data vector.
%   y          - Vertical axis data vector.
%   y_lim_inf  - Lower limit for the y-axis.
%   y_lim_sup  - Upper limit for the y-axis.
%   plot_title - String for the plot title.
%   x_label    - String for the x-axis label.
%   y_label    - String for the y-axis label.
%   color      - Character or string for the plot color.

function stemPloter(x, y, y_lim_inf, y_lim_sup, plot_title, x_label, y_label, color)

    % Create the main stem plot with specified color and line width.
    stem(x, y, color, 'LineWidth', 2);

    % Set the horizontal axis limits to fit the data perfectly.
    xlim([min(x) max(x)]);

    % Set the vertical axis limits using the provided values.
    ylim([y_lim_inf, y_lim_sup]);

    % Display the grid for better readability.
    grid on;

    % Set the title of the plot.
    title(plot_title);

    % Set the x-axis label, interpreting it as LaTeX.
    xlabel(x_label, 'Interpreter', 'latex');

    % Set the y-axis label, interpreting it as LaTeX.
    ylabel(y_label, 'Interpreter', 'latex');