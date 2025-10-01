close all;

%% User Inputs & Problem Definition
% Prompt the user to define the beam's physical properties and loads.

% Get the total length of the beam. The input is evaluated as a number.
L = input('Enter the total beam length (L): ');

% Get the loading function as a string.
% An example is provided to guide the user on the correct format.
% The 's' flag ensures the input is treated as literal text.
prompt_text = 'Enter the loading function (e.g., 10*<x-0>^0 - 50<x-2>^-1):\n';
input_str = input(prompt_text, 's');

%% Initialization of Result Vectors
magnitudes = []; % Vector for 'q' values
offsets = []; % Vector for 'a' values
exponents = []; % Vector for 'n' values

%% Pre-processing: Standardize Operators
% Replace all subtractions with "plus negative"
% to ensure the sign is correctly associated with its magnitude 'q'.
% Example: "A - B" becomes "A + -B"
no_space_str = erase(input_str, whitespacePattern);

pattern_lookbehind = '(?<=>\^[-]?\d+)-';
processed_str = regexprep(no_space_str, pattern_lookbehind, '+-');

%% Term Splitting
% We split the string by '+' to get a cell array of individual terms.
terms = strsplit(processed_str, '+');

%% Parsing Loop
% We iterate through each term, extract the parameters using a regexp
% pattern designed for the q<x-a>^n format.

fprintf('Parsing terms...\n');
for i = 1:length(terms)

    current_term = terms{i};

    pattern = '(.*?)\s*\*?\s*<x-([^>]+)>\^(.+)';

    % Extract the tokens using the new pattern
    tokens = regexp(current_term, pattern, 'tokens', 'once');

    % Check if the pattern was found
    if ~isempty(tokens)

        q_str = tokens{1};
        a_str = tokens{2};
        n_str = tokens{3};
        
        % Handle the case where the magnitude is just a sign (e.g., -<x-a>^n)
        if isempty(q_str) || strcmp(q_str, '-') || strcmp(q_str, '+')
            q_str = [q_str, '1']; % Becomes '-1' or '+1'
        end

        % Convert string tokens to numbers using str2num for expressions
        q = str2num(q_str);
        a = str2num(a_str);
        n = str2num(n_str);

        % Append the extracted values to their respective vectors
        magnitudes(end+1) = q;
        offsets(end+1)    = a;
        exponents(end+1)  = n;

        fprintf('Term %d: q=%.2f, a=%.2f, n=%d\n', i, q, a, n);
    else
        fprintf('Term %d: "%s" -> SKIPPED (Invalid format)\n', i, current_term);
    end
end

%% Setup for Calculation and Plotting
x = 0:0.001:L; % Create the domain vector for the beam

% Initialize Shear Force (V) and Bending Moment (M) vectors with zeros
q_plot = zeros(size(x)); % Vetor para a curva das cargas distribuídas
V = zeros(size(x));
M = zeros(size(x));

% Define the singularity function helper (Macaulay brackets)
% The (n>=0) term acts as a master switch. If n is negative, the whole
% expression becomes zero.
singularity = @(x, a, n) (n >= 0) .* (x > a) .* (x - a).^n;

%% Programmatic and Automated Calculation
% This advanced version replaces the switch-case with a universal mathematical
% rule for singularity function integration, making the code more concise
% and scalable.

for i = 1:length(magnitudes)
    % Get parameters for the current term
    q = magnitudes(i);
    a = offsets(i);
    n = exponents(i);

    % Universal Integration Rules
    
    % Contribution to Shear (V)
    v_exp = n + 1;
    v_den = max(1, v_exp); % This handles all cases of n
    V = V + (q / v_den) * singularity(x, a, v_exp);

    % Contribution to Moment (M)
    m_exp = n + 2;
    m_den = v_den * max(1, m_exp); % The denominators accumulate
    M = M + (q / m_den) * singularity(x, a, m_exp);
end



%% Enhanced Plotting Block

% Inverting the sign convention (as per your code)
V = -V;
M = -M;

nan_index = find(isnan(V));
V(nan_index) = V(nan_index - 1);

V(end) = 0; M(end) = 0;

%dyna_padder = @(in_vector) max([abs(min(in_vector)), max(in_vector)]);

% Creates the vector for the zero-axis line
y = zeros(size(x)); 

figure('Name', 'Beam Analysis Diagrams');

% Shear Force Diagram
subplot(2, 1, 1);
plot(x, V, 'LineWidth', 1.5, 'Color', 'b');
hold on;
plot(x, y, 'k--');
grid on;
box on;
title('Shear Force Diagram');
ylabel('Shear Force (N)');
xlabel('Position (x)');
fill([x, fliplr(x)], [V, fliplr(y)], 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
xlim([min(x) max(x)]);
ylim([min(V) max(V)]);
hold off;

% Bending Moment Diagram
subplot(2, 1, 2);
plot(x, M, 'LineWidth', 1.5, 'Color', 'r'); % Red color to differentiate
hold on;
plot(x, y, 'k--');
grid on;
box on;
title('Bending Moment Diagram');
ylabel('Bending Moment (Nm)');
xlabel('Position (x)');
fill([x, fliplr(x)], [M, fliplr(y)], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
xlim([min(x) max(x)]);
ylim([min(M) max(M)]);
hold off;