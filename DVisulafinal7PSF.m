%% Step 1: Load Data and Parameters
pathSave = 'E:\0620fudan\';
folderName = 'Data_bad2\';%Dataset
addpath(genpath(fullfile(pathSave, folderName)));

load([pathSave, folderName, 'RcvData.mat'], 'RcvData');
load([pathSave, folderName, 'Para.mat'], 'Receive', 'Trans', 'na', 'dtheta');

connect_index = Trans.Connector;
fs = Receive(1).decimSampleRate * 1e6;
samplesPer = Receive(1).endSample;
nAngles = na;  % 21 angles, plane waves
angles = linspace(-5, 5, nAngles);  % Degrees

% Imaging settings
t_start = 10e-6;
t_end = 24e-6;
v_sound = 2569;  % m/s
startIdx = round(t_start * fs);
endIdx = round(t_end * fs);
depthLen = endIdx - startIdx + 1;

% Volume size (x × y × z)
x_mm = linspace(0, 50, 128);
y_mm = linspace(0, 34, 128);
z_mm = linspace(0, 5, depthLen);

%% Step 2: Rearranging RF Data
rfData = RcvData{1}(:,:,1);
Rcvdata_Trans = rfData(1:2*nAngles*samplesPer, connect_index);

rfData2 = zeros(nAngles*samplesPer, 256);
rfData2(:, 1:128)   = Rcvdata_Trans(nAngles*samplesPer+1:end, 1:128);
rfData2(:, 129:256) = Rcvdata_Trans(1:nAngles*samplesPer, 129:256);

%% Step 3: Simulate RCA TX-RX alternation and compounding
volume = zeros(128, 128, depthLen);  % [x, y, z]

for k = 1:nAngles
    bscan_rowTx = zeros(depthLen, 128);  % TX: row, RX: col
    bscan_colTx = zeros(depthLen, 128);  % TX: col, RX: row

    % Extract A-scans for this angle
    for ch = 1:256
        rfLine = rfData2((k-1)*samplesPer+1 : k*samplesPer, ch);
        segment = rfLine(startIdx:endIdx);
        if ch <= 128
            bscan_rowTx(:, ch) = segment;   % Row TX (1-128)
        else
            bscan_colTx(:, ch-128) = segment; % Col TX (129-256)
        end
    end

    % Envelope + log compression
    env_row = 20 * log10(abs(bscan_rowTx) + eps);
    env_col = 20 * log10(abs(bscan_colTx) + eps);

    env_row = max(env_row, max(env_row(:)) - 40);
    env_col = max(env_col, max(env_col(:)) - 40);

    env_row = (env_row - min(env_row(:))) / (max(env_row(:)) - min(env_row(:)));
    env_col = (env_col - min(env_col(:))) / (max(env_col(:)) - min(env_col(:)));

    % Convert to 3D slices
    for z = 1:depthLen
        vol_slice = (env_row(z, :)' * ones(1, 128) + ...
                     ones(128, 1) * env_col(z, :)) / 2;  % RCA fusion
        volume(:, :, z) = volume(:, :, z) + vol_slice;
    end
end

% XDoppler Compounding: Average over all 21 angles
volume = volume / nAngles;

% Normalize final 3D volume
volume = (volume - min(volume(:))) / (max(volume(:)) - min(volume(:)));

%% Step 4: Detect Local Maxima (PSF peaks)
localMax = imregionalmax(volume);
maxima = volume .* localMax;

% Optional: Gaussian kernel fitting for visualization
gKernel = fspecial3('gaussian', [5 5 5]);
corrMap = imfilter(maxima, gKernel, 'replicate');

% Apply 1/3 exponent for density rendering
densityMap = corrMap.^(1/3);

%% Step 5: Visualization
[X, Y, Z] = meshgrid(x_mm, y_mm, z_mm);  % Physical coordinates

if exist('volshow', 'file')
    figure('Color', 'w');
    volshow(densityMap, ...
        'Colormap', parula(256), ...
        'Alphamap', linspace(0, 1, 256)', ...
        'BackgroundColor', [1 1 1]);  % white background

    title('RCA XDoppler 3D Volume with PSF Maxima', ...
        'FontName', 'Times New Roman', 'FontSize', 14);
else
    % Fallback Slice Viewer
    figure('Color', 'w');
    idx_x = round(size(densityMap, 1)/2);
    idx_y = round(size(densityMap, 2)/2);
    idx_z = round(size(densityMap, 3)/2);

    h = slice(densityMap, idx_x, idx_y, idx_z);
    shading interp;
    colormap(parula(256));
    cb = colorbar;
    cb.Label.String = 'Normalized Density (1/3 power)';
    cb.Label.FontName = 'Times New Roman';

    set(h, 'AlphaData', get(h, 'CData'), ...
        'AlphaDataMapping', 'scaled', ...
        'FaceAlpha', 'interp', ...
        'EdgeAlpha', 0.3);

    xlabel('X (mm)', 'FontName', 'Times New Roman');
    ylabel('Y (mm)', 'FontName', 'Times New Roman');
    zlabel('Z (Depth, mm)', 'FontName', 'Times New Roman');

    title('RCA XDoppler 3D PSF Density Volume', ...
        'FontName', 'Times New Roman', 'FontSize', 14);
    set(gca, 'FontName', 'Times New Roman');
end
