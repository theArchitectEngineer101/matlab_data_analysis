# 🌊 Discrete Convolution Animation in MATLAB

This repository contains a set of MATLAB scripts designed to visually demonstrate the step-by-step process of signal convolution in the discrete-time domain. This tool serves as an excellent educational aid for understanding fundamental concepts in Signals and Systems, Digital Signal Processing, and Linear Systems.

## 🎥 Demonstration

The animation below illustrates the discrete convolution process in action, showing the flipping and shifting of the impulse response, the point-wise multiplication, and the cumulative summation to form the output signal.

*(Suggestion: Record a GIF of your animation and add it here for maximum visual impact.)*

## 🚀 Features

The project is centered on the `discreteConvAnim.m` script, which offers the following features:

* **Detailed Animation:** Animates the discrete convolution of two input signals (`x_entry_signal` and `h_impulse_response`), dynamically displaying the signal flipping, shifting, element-wise multiplication, and cumulative summation.

* **Video Export:** Generates a high-quality (100%) and 30-fps `.mp4` video of the entire animation.

* **Interval-Based GIF Creation:** Allows the creation of multiple animated `.gif` files, each corresponding to a specific time interval (normalized from 0 to 1) of the total animation.

* **High-Resolution Snapshots:** Captures high-resolution (300 DPI) `.png` images at specific time points (normalized from 0 to 1) of the animation.

* **File Organization:** All exported media (video, GIFs, snapshots) are saved in an organized manner into a single folder, named after the video file or as "exports" by default.

## ⚙️ Requirements

* **MATLAB R2021a** or newer (due to the use of `exportgraphics`). No additional toolboxes are required.

## ▶️ How to Use

To run the animation, ensure all `.m` files (`discreteConvAnim.m` and its helper functions `stemPloter.m`, `videoRecorder.m`, `gifRecorder.m`, `snapshotRecorder.m`) are in your MATLAB path. Then, call the function from the MATLAB command window.

**Basic Example (On-Screen Animation Only):**

```matlab
% Define your input signal and impulse response
x_signal = [1 1 1 1];     % Input signal
h_signal = [0.5 1 0.5]; % Impulse response

% Call the function to start the discrete convolution animation
conv_result = discreteConvAnim(x_signal, h_signal);
```

**Advanced Example (Full Export):**

```matlab
% Define the signals
x_signal = [1 2 1 -1];
h_signal = [1 1 1];

% Define the export parameters
video_filename   = 'conv_example';
gif_intervals = [0 0.25; 0.4 0.6; 0.8 1.0]; % Start, middle, and end
snap_points  = [0.1 0.5 0.9]; % Snapshots at 10%, 50%, and 90% of the time

% Call the function with all parameters
conv_result = discreteConvAnim(x_signal, h_signal, video_filename, gif_intervals, snap_points);

% All files (conv_example.mp4, conv_example_1.gif, 
% conv_example_snap_10_pct.png, etc.) will be saved in the 'conv_example' folder.
```