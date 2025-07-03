%% Step 1: Load Data & Parameters
pathSave = 'E:\0620fudan\';
folderName = 'Data_lcoNew_0min\';%yourowndata
addpath(genpath(fullfile(pathSave, folderName)));

load([pathSave, folderName, 'RcvData.mat'], 'RcvData');
load([pathSave, folderName, 'Para.mat'], 'Receive', 'Trans', 'na', 'dtheta');

connect_index = Trans.Connector;
fs = Receive(1).decimSampleRate * 1e6;
samplesPer = Receive(1).endSample;
nAngles = na;   % Total scan lines (e.g., 21)
k = 11;         % Scan line index

%% Step 2: Define Time Window (10–24 µs)
t_start = 10e-6;
t_end   = 24e-6;
v_sound = 2569;  % m/s
startIdx = round(t_start * fs);
endIdx   = round(t_end * fs);
depthLen = endIdx - startIdx + 1;
depth_mm = (t_end - t_start) * v_sound * 1000 / 2;

%% Step 3: Rearrange RF Data from RcvData
rfData = RcvData{1}(:,:,1);
Rcvdata_Trans = rfData(1:2*nAngles*samplesPer, connect_index);

rfData2 = zeros(nAngles*samplesPer, 256);
rfData2(:, 1:128) = Rcvdata_Trans(nAngles*samplesPer+1:end, 1:128);
rfData2(:, 129:256) = Rcvdata_Trans(1:nAngles*samplesPer, 129:256);

%% Step 4: Extract A-scans for Scan Line k (raw RF)
bscan_left = zeros(depthLen, 129);
bscan_right = zeros(depthLen, 128);

for ch = 1:129
    rfLine = rfData2((k-1)*samplesPer+1 : k*samplesPer, ch);
    bscan_left(:, ch) = rfLine(startIdx:endIdx);
end

for ch = 129:256
    rfLine = rfData2((k-1)*samplesPer+1 : k*samplesPer, ch);
    bscan_right(:, ch-128) = rfLine(startIdx:endIdx);
end

%% Step 5: SVD Filter (keep top N components)
N = 3;
[U1,S1,V1] = svd(bscan_left, 'econ');
[U2,S2,V2] = svd(bscan_right, 'econ');

bscan_left_filtered = U1(:,1:N) * S1(1:N,1:N) * V1(:,1:N)';
bscan_right_filtered = U2(:,1:N) * S2(1:N,1:N) * V2(:,1:N)';

%% Step 6: Envelope Detection + Log Compression
bscan_left_env = 20 * log10(abs(bscan_left_filtered) + eps);
bscan_right_env = 20 * log10(abs(bscan_right_filtered) + eps);

% Clip to 40 dB and normalize
bscan_left_env = max(bscan_left_env, max(bscan_left_env(:)) - 40);
bscan_right_env = max(bscan_right_env, max(bscan_right_env(:)) - 40);

bscan_left_norm = (bscan_left_env - min(bscan_left_env(:))) / ...
                  (max(bscan_left_env(:)) - min(bscan_left_env(:)));
bscan_right_norm = (bscan_right_env - min(bscan_right_env(:))) / ...
                   (max(bscan_right_env(:)) - min(bscan_right_env(:)));

%% Step 7: Define Axes (physical scale)
z_mm = linspace(0, depth_mm, depthLen);
x_left_mm  = linspace(0, 50, 129);
x_right_mm = linspace(0, 34, 128);

%% Step 8: Plot B-scan: Channels 1–129
figure('Color', 'w');
imagesc(x_left_mm, z_mm, bscan_left_norm);
axis image;
set(gca, 'YDir', 'normal');
colormap(parula(256));
cb1 = colorbar;
cb1.Label.String = 'Normalized Amplitude (dB)';
cb1.Label.FontName = 'Times New Roman';

xlabel('Lateral Position (mm)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Depth (mm)', 'FontName', 'Times New Roman', 'FontSize', 12);
title('B-scan with SVD: Channels 1–129 (Lateral View)', 'FontName', 'Times New Roman', 'FontSize', 14);
set(gca, 'FontName', 'Times New Roman');

%% Step 9: Plot B-scan: Channels 129–256
figure('Color', 'w');
imagesc(x_right_mm, z_mm, bscan_right_norm);
axis image;
set(gca, 'YDir', 'normal');
colormap(parula(256));
cb2 = colorbar;
cb2.Label.String = 'Normalized Amplitude (dB)';
cb2.Label.FontName = 'Times New Roman';

xlabel('Elevational Position (mm)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Depth (mm)', 'FontName', 'Times New Roman', 'FontSize', 12);
title('B-scan with SVD: Channels 129–256 (Orthogonal View)', 'FontName', 'Times New Roman', 'FontSize', 14);
set(gca, 'FontName', 'Times New Roman');
