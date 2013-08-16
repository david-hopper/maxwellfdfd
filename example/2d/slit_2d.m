clear all; close all; clear classes; clc;

%% Set flags.
inspect_only = false;

%% Solve the system.
gray = [0.5 0.5 0.5];  % [r g b]
flux_y = -1000;
flux_x1 = -200; flux_x2 = 200;

% % (silver)
% [E, H, obj_array, src_array, J] = maxwell_run(...
% 	'OSC', 1e-9, 1180, ...
% 	'DOM', {'vacuum', 'none', 1.0}, [-1070, 1070; -2500, 2500; 0, 10], 10, BC.p, [100 100 0],...
% 	'OBJ', ...
% 		{'vacuum', 'b', 1.0}, Rectangle(Axis.y, flux_y, [0 10; flux_x1 flux_x2]), ...
% 		{'CRC/Ag', gray}, Box([-1070, -80; -1500, -500; 0, 10]), Box([80, 1070; -1500, -500; 0, 10]), ...  % metal slit
% 	'SRCM', PlaneSrc(Axis.y, -2000, Axis.z), ...
% 	inspect_only);
% 
% % (true PEC)
% [E, H, obj_array, src_array, J] = maxwell_run(...
% 	'OSC', 1e-9, 1180, ...
% 	'DOM', {'vacuum', 'none', 1.0}, [-1070, 1070; -2500, 2500; 0, 10], 10, BC.p, [100 100 0],...
% 	'OBJ', ...
% 		{'vacuum', 'b', 1.0}, Rectangle(Axis.y, flux_y, [0 10; flux_x1 flux_x2]), ...
% 		{'PEC', gray, Inf}, Box([-1070, -80; -1500, -500; 0, 10]), Box([80, 1070; -1500, -500; 0, 10]), ...  % metal slit
% 	'SRCM', PlaneSrc(Axis.y, -2000, Axis.z), ...
% 	inspect_only);
% 
% % (no metal)
% [E, H, obj_array, src_array, J] = maxwell_run(...
% 	'OSC', 1e-9, 1180, ...
% 	'DOM', {'vacuum', 'none', 1.0}, [-1070, 1070; -2500, 2500; 0, 10], 10, BC.p, [100 100 0],...
% 	'OBJ', {'vacuum', 'b', 1.0}, Plane(Axis.y, flux_y), ...
% 	'SRCM', PlaneSrc(Axis.y, -2000, Axis.z), ...
% 	inspect_only);
% 
% (modal source)
[E, H, obj_array, src_array, J] = maxwell_run(...
	'OSC', 1e-9, 1180, ...
	'DOM', {'vacuum', 'none', 1.0}, [-1070, 1070; -2500, 2500; 0, 10], 10, BC.p, [100 100 0],...
	'OBJ', ...
		{'vacuum', 'b', 1.0}, Rectangle(Axis.y, flux_y, [0 10; flux_x1 flux_x2]), ...
		{'CRC/Ag', gray}, Box([-1070, -80; -1500, -500; 0, 10]), Box([80, 1070; -1500, -500; 0, 10]), ...  % metal slit
	'SRCM', ModalSrc(Axis.y, -1100), ...
	inspect_only);
% 
% % (point source)
% [E, H, obj_array, src_array, J] = maxwell_run(...
% 	'OSC', 1e-9, 1180, ...
% 	'DOM', {'vacuum', 'none', 1.0}, [-1070, 1070; -2500, 2500; 0, 10], 10, BC.p, [100 100 0],...
% 	'OBJ', ...
% 		{'vacuum', 'b', 1.0}, Rectangle(Axis.y, flux_y, [0 10; flux_x1 flux_x2]), ...
% 		{'CRC/Ag', gray}, Box([-1070, -80; -1500, -500; 0, 10]), Box([80, 1070; -1500, -500; 0, 10]), ...  % metal slit
% 	'SRCM', PointSrc(Axis.z, [0, -2000, 5]), ...
% 	inspect_only);
% 
% % (rectangular source)
% xc = 101;
% solveropts.eqtype = EquationType(FT.e, GT.prim);
% [E, H, obj_array, src_array, J] = maxwell_run(...
% 	'OSC', 1e-9, 1180, ...
% 	'DOM', {'vacuum', 'none', 1.0}, [-1070, 1070; -2500, 2500; 0, 10], 10, BC.p, [100 100 0],...
% 	'OBJ', ...
% 		{'vacuum', 'b', 1.0}, Rectangle(Axis.y, flux_y, [0 10; flux_x1 flux_x2]), ...
% 		{'CRC/Ag', gray}, Box([-1070, -80; -1500, -500; 0, 10]), Box([80, 1070; -1500, -500; 0, 10]), ...  % metal slit
% 	'SRCM', RectSrc(Axis.y, -2000, [0 10; xc-80 xc+80], Axis.z), solveropts, inspect_only);

if ~inspect_only
	%% Visualize the solution.
	figure
	clear opts
	opts.withobjsrc = true;
	opts.withabs = true;  % true: abs(solution), false: real(solution)
	opts.withpml = false;  % true: show PML, false: do not show PML
	opts.withgrid = false;
% 	opts.withinterp = false;
% 	opts.cscale = 1e-1;
	z_loc = 0;
	vis2d(E{Axis.x}, Axis.z, z_loc, obj_array, src_array, opts)

	%% Calculate the power flux through the slit.
	power = powerflux_patch(E, H, Axis.y, flux_y, [0 10; flux_x1 flux_x2]);
	fprintf('power = %e\n', power);
end
