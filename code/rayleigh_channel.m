%% Rayleigh Flat Fading Channel: h(t) = (hr + j*hi)*delta(t)
% Applies one complex fading coefficient per symbol duration Ts

% Determine number of channel coefficients (N_sym from TX.m, or default standalone)
if exist('N_sym', 'var')
    num_ch = N_sym;
elseif exist('N', 'var')
    num_ch = N;
else
    num_ch = 1e5;
end

% 1. Generate Real and Imaginary Gaussian Components
% Mean = 0, Variance = 1/2 --> Standard Deviation = sqrt(1/2)
sigma = sqrt(1/2);
h_r = sigma * randn(1, num_ch);
h_i = sigma * randn(1, num_ch);

% 2. Construct the Complex Channel Coefficient: h = hr + j*hi
h = h_r + 1i * h_i;

% 3. Extract Amplitude (Ah) and Phase (theta_h) in [0, 2*pi]
A_h = abs(h);                        % Rayleigh distributed amplitude
theta_h = mod(angle(h), 2 * pi);     % Uniformly distributed phase over [0, 2*pi]

% 4. Apply Channel to the Transmitted Signal
if exist('s_t', 'var') && exist('L', 'var')
    % Keep the channel constant over each symbol duration Ts (flat slow fading)
    h_upsampled = repelem(h, L);
    r_t = h_upsampled .* s_t;        % Signal after passing through h(t)
elseif exist('x_k', 'var')
    r_k = h .* x_k;                  % Baseband equivalent fallback
end