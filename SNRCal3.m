% File path
filePath = 'E:\2025\3Dbattery\ascan256.xlsx';

% Read the first column of data
data = readmatrix(filePath);        % Automatically detects Excel format
ascan = data(:, 1);                 % Extract first column

% Plot the A-scan signal
figure('Color','w');
plot(ascan, 'LineWidth', 1.5);
xlabel('Sample Index', 'FontName', 'Times New Roman');
ylabel('Amplitude', 'FontName', 'Times New Roman');
title('A-scan Signal from Column 1 of ascan256.xlsx', 'FontName', 'Times New Roman');
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

% Define signal and noise regions (manually or from peak)
signal_window = ascan(230:240);     % Likely aluminum echo
noise_window  = ascan(100:200);     % Quiet baseline, no echo

% Compute SNR
A_signal = max(abs(signal_window));
A_noise  = std(noise_window);
SNR_dB   = 20 * log10(A_signal / A_noise);

% Display result
fprintf('SNR = %.2f dB\n', SNR_dB);
