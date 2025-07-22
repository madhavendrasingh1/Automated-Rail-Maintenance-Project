clear; clc;
addpath('k-Wave');  % Replace with your actual path if needed

% Grid and time setup
Nx = 120; Ny = 60; dx = 1e-3; dy = 1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy);
c0 = 5900;
kgrid.makeTime(c0, 0.3);

% Medium properties
default_c = c0 * ones(Nx, Ny);
default_rho = 7850 * ones(Nx, Ny);

% DAS sensor line
sensor.mask = zeros(Nx, Ny);
for i = 1:50
    sensor.mask(70 + i, 30) = 1;
end
sensor.record = {'p'};

% Defect list and size
defect_list = {'no_defect', 'crack', 'inclusion', 'surface_fault'};
num_samples_per_defect = 125;  % ✅ 4 types × 125 = 500 rows
feature_table = [];

for d = 1:length(defect_list)
    defect_type = defect_list{d};

    for s = 1:num_samples_per_defect
        fprintf('Simulating: %s | Sample %d of %d\n', defect_type, s, num_samples_per_defect);

        % Medium reset
        medium.sound_speed = default_c;
        medium.density = default_rho;

        % Insert random defect geometry variation
        switch defect_type
            case 'crack'
                x = randi([95, 105]);
                y = randi([20, 35]);
                medium.sound_speed(x:x+3, y:y+5) = 2500;
            case 'inclusion'
                x = randi([85, 95]);
                y = randi([15, 30]);
                medium.sound_speed(x:x+3, y:y+5) = 8000;
            case 'surface_fault'
                x = randi([70, 80]);
                y = randi([3, 10]);
                medium.sound_speed(x:x+3, y:y+3) = 3000;
        end

        % Source setup
        source.p_mask = zeros(Nx, Ny);
        source.p_mask(30, 30) = 1;
        source_freq = 1e6;
        source.p = toneBurst(1 / kgrid.dt, source_freq, 5);

        % Run simulation
        input_args = {'DisplayMask', sensor.mask, 'PlotPML', false, 'DataCast', 'single'};
        sensor_output = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

        % Access output
        data = sensor_output.p;
        fs = 1 / kgrid.dt;
        t_us = kgrid.t_array * 1e6;
        nSensors = size(data, 1);

        ToF = zeros(1, nSensors);
        EchoAmp = zeros(1, nSensors);
        ReflectLoc = zeros(1, nSensors);

        for i = 1:nSensors
            signal = double(data(i, :));
            signal = signal - mean(signal);
            abs_sig = abs(signal);

            % Manual peak detection
            peak_threshold = 0.05 * max(abs_sig);
            peaks = [];
            locs = [];
            for j = 2:length(abs_sig)-1
                if abs_sig(j) > peak_threshold && abs_sig(j) > abs_sig(j-1) && abs_sig(j) > abs_sig(j+1)
                    peaks(end+1) = abs_sig(j);
                    locs(end+1) = j;
                end
            end

            if ~isempty(locs)
                ToF(i) = t_us(locs(1));
                EchoAmp(i) = peaks(1);
                ReflectLoc(i) = locs(1);
            else
                ToF(i) = NaN;
                EchoAmp(i) = 0;
                ReflectLoc(i) = NaN;
            end
        end

        % Store row
        row = [ToF, EchoAmp, ReflectLoc];
        row_table = array2table(row);
        row_table.defect_label = {defect_type};
        feature_table = [feature_table; row_table];
    end
end

% Label columns
ToF_names = arrayfun(@(i) sprintf('ToF_sensor_%d', i), 1:nSensors, 'UniformOutput', false);
Amp_names = arrayfun(@(i) sprintf('Amp_sensor_%d', i), 1:nSensors, 'UniformOutput', false);
Refl_names = arrayfun(@(i) sprintf('ReflLoc_sensor_%d', i), 1:nSensors, 'UniformOutput', false);
all_names = [ToF_names, Amp_names, Refl_names, {'defect_label'}];
feature_table.Properties.VariableNames = all_names;

% Save
writetable(feature_table, 'DAS_Feature_Extracted_Merged2.csv');
disp('✅ 500 samples saved to DAS_Feature_Extracted_Merged.csv');
