clear all; close all; clear classes; clc;

%% Set flags.
isnew = true;
inspect_only = false;

%% Solve the system.
flux_loc = 10;
wvlen = 20;
if isnew
	% (line along z-direction)
	axis = Axis.z;
	[E, H, obj_array, src_array, J] = maxwell_run(...
		'OSC', 1e-9, wvlen, ...
		'DOM', {'vacuum', 'none', 1.0}, [-60, 60; -60, 60; 0, 1], 1, BC.p, [10 10 0], ...
		'OBJ', {'vacuum', 'none', 1.0}, Plane(Axis.y, flux_loc), ...
		'SRC', LineSrc(axis, [0 0]), ...  % LineSrc(axis, intercept)
		inspect_only);  
	
% 	% (line along x-direction)
% 	axis = Axis.x;
% 	[E, H, obj_array, src_array, J] = maxwell_run(...
% 		'OSC', 1e-9, wvlen, ...
% 		'DOM', {'vacuum', 'none', 1.0}, [-50, 50; -60, 60; 0, 1], 1, BC.p, [0 10 0], ...
% 		'OBJ', {'vacuum', 'none', 1.0}, Plane(Axis.y, flux_loc), ...
% 		'SRC', LineSrc(axis, [0 0.5]), ...  % LineSrc(axis, intercept)
% 		inspect_only);  

% 	% (line along y-direction)
% 	axis = Axis.y;
% 	[E, H, obj_array, src_array, J] = maxwell_run(...
% 		'OSC', 1e-9, wvlen, ...
% 		'DOM', {'vacuum', 'none', 1.0}, [-60, 60; -50, 50; 0, 1], 1, BC.p, [10 0 0], ...
% 		'OBJ', {'vacuum', 'none', 1.0}, Plane(Axis.y, flux_loc), ...
% 		'SRC', LineSrc(axis, [0.5 0]), ...  % LineSrc(axis, intercept)
% 		inspect_only);  

% 	% (polarization ~= axis)
% 	polarization = Axis.z;
% 	[E, H, obj_array, src_array, J] = maxwell_run(...
% 		'OSC', 1e-9, wvlen, ...
% 		'DOM', {'vacuum', 'none', 1.0}, [-50, 50; -60, 60; 0, 1], 1, BC.p, [0 10 0], ...
% 		'OBJ', {'vacuum', 'none', 1.0}, Plane(Axis.y, flux_loc), ...
% 		'SRC', LineSrc(Axis.x, [0 0], polarization, 1.0, pi/4, wvlen), ...  % LineSrc(axis, intercept)
% 		inspect_only);
% 	axis = polarization;


% 	% (oblique incidence)
% 	axis = Axis.x;
% 	[E, H, obj_array, src_array, J] = maxwell_run(...
% 		'OSC', 1e-9, wvlen, ...
% 		'DOM', {'vacuum', 'none', 1.0}, [-50, 50; -60, 60; 0, 1], 1, BC.p, [0 10 0], ...
% 		'OBJ', {'vacuum', 'none', 1.0}, Plane(Axis.y, flux_loc), ...
% 		'SRC', LineSrc(axis, [0 0.5], axis, 1, pi/4, wvlen), ...  % LineSrc(axis, intercept, polarization, IorK, theta, wvlen)
% 		inspect_only);  
	if ~inspect_only
		save(mfilename, 'E', 'H', 'obj_array', 'src_array');
	end
else
	load(mfilename);
end

%% Visualize the solution.
figure
clear opts;
opts.withobjsrc = true;
vis2d(E{axis}, Axis.z, 0, obj_array, src_array, opts)

%% Calculate the power emanating from the source.
power = powerflux_patch(E, H, Axis.y, flux_loc);
fprintf('power = %e\n', power);
