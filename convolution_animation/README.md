# 🌊 Convolution Animations (Continuous and Discrete) in MATLAB

![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=for-the-badge&logo=mathworks&logoColor=white)

This repository contains MATLAB scripts designed to visually demonstrate the step-by-step process of signal convolution, covering both discrete and continuous-time domains. These tools serve as an excellent educational aid for understanding fundamental concepts in Signals and Systems, Digital Signal Processing, and Linear Systems.

## 🎥 Demonstration

The animation below illustrates the discrete convolution process in action, showing the flipping and shifting of the impulse response, the point-wise multiplication, and the cumulative summation to form the output signal.

*(Note: I suggest you record a GIF of your animation and add it here for maximum visual impact.)*

## 🚀 Features

This project includes two main animation scripts:

* **`DiscreteConvAnim.m`**: Animates the discrete convolution of two input signals (`x_entry_signal` and `h_impulse_response`). The animation dynamically displays the signal flipping, shifting, element-wise multiplication, and cumulative summation to form the convoluted output signal.

* **`ContinuousConvAnim.m`**: Animates the continuous convolution of two input signals. The process is simulated using discrete samples to visualize the signal flipping, shifting, multiplication, and the integration-like accumulation process that forms the output signal.

## ⚙️ Requirements

* **MATLAB R2016b** or newer. No additional toolboxes are required.

## ▶️ How to Use

To run the animations, ensure both `.m` files are in your MATLAB path. Then, call the desired function from the MATLAB command window.

**Example for Discrete Convolution:**
```matlab
% Define your input signal and impulse response
x_disc = [1 1 1 1]; % Input signal
h_disc = [0.5 1 0.5];     % Impulse response

% Call the function to start the discrete convolution animation
conv_result_discrete = DiscreteConvAnim(x_disc, h_disc);
```

**Example for Continuous Convolution:**
```matlab
% Define a rectangular pulse and an exponential impulse response
x_cont = ones(1, 20); % Input signal
h_cont = exp(-0.2*(0:19)); % Impulse response

% Call the function to start the continuous convolution animation
conv_result_continuous = ContinuousConvAnim(x_cont, h_cont);