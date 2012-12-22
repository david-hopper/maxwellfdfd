%% PointSrcM
% Concrete subclass of <Source.html |Source|> representing a magnetic point
% dipole source.

%%% Description
% |PointSrcM| places an oscillating magnetic point dipole at the location given
% in the constructor.

%%% Construction
%  src = PointSrcM(polarization_axis, location)
%  src = PointSrcM(polarization_axis, location, Im)
% 
% *Input Arguments*
%
% * |polarization_axis|: direction of the dipole.  It should be one of |Axis.x|,
% |Axis.y|, |Axis.z|.
% * |location|: location of the dipole in the form of |[x, y, z]|.
% * |Im|: amplitude of the magnetic current that the dipole drives.

%%% Note
% In the finite-difference grid, |PointSrcM| is located at one of the _H_-field
% points.  This poses a condition on |location| argument in the constructor: the
% location in the directions normal to the dipole polarization should be at
% primary grid points, whereas the location in the direction along the dipole
% polarization should be at a dual grid point.  Therefore, make sure that the
% location of the dipole does not overlap with the locations of the vertices of
% <Shape.html |Shape|> in the direction along the dipole polarization; otherwise
% dynamic grid generation in <moxwell_run.html |maxwell_run|> will fail.

%%% Example
%   % Create an instance of PointSrc.
%   src = PointSrcM(Axis.z, [0 0 0.5]);  % z = 0.5 should not be primary grid point
%
%   % Use the constructed src in maxwell_run().
%   [E, H] = maxwell_run({INITIAL ARGUMENTS}, 'SRC', src);

%%% See Also
% <PointSrc.html |PointSrc|>, <PlaneSrc.html |PlaneSrc|>, <maxwell_run.html
% |maxwell_run|>

classdef PointSrcM < Source
	
	properties (SetAccess = immutable)
		polarization  % one of Axis.x, Axis.y, Axis.z
		location  % [x, y, z];
		Im  % current, e.g., Jz * dx * dy
	end
	
	methods
		function this = PointSrcM(polarization_axis, location, Im)
			chkarg(istypesizeof(polarization_axis, 'Axis'), ...
				'"polarization_axis" should be instance of Axis.');
			chkarg(istypesizeof(location, 'real', [1, Axis.count]), ...
				'"location" should be length-%d row vector with real elements.', Axis.count);
			if nargin < 3  % no I
				Im = 1.0;
			end
			chkarg(istypesizeof(Im, 'complex'), '"I" should be complex.');
			
			l = cell(Axis.count, GK.count);
			for w = Axis.elems
				if w == polarization_axis
					l{w, GK.dual} = location(w);
				else
					l{w, GK.prim} = location(w);
				end
			end
			point = Point(location);
			this = this@Source(l, point);
			this.polarization = polarization_axis;
			this.location = location;
			this.Im = Im;
		end
				
		function [index_cell, Jw_patch] = generate_kernel(this, w_axis, grid3d)
			index_cell = cell(1, Axis.count);
			[q, r, p] = cycle(this.polarization);  % q, r: axes normal to polarization axis p
			if w_axis == p
				Jw_patch = [];
			else  % w_axis == q or r
				indM = NaN(1, Axis.count);
				for v = Axis.elems
					l = this.location(v);
					if v == p
						g = GK.dual;
					else  % v == q or r
						g = GK.prim;
					end
					iv = ind_for_loc(l, v, g, grid3d);
					indM(v) = iv;
				end
				dq = grid3d.dl{q, GK.prim}(indM(q));
				dr = grid3d.dl{r, GK.prim}(indM(r));
				I = this.Im / (dq * dr);  % (magnetic dipole) = (electric current) * (area)
				
				
				if w_axis == q
					% Assign Jq.
					index_cell{p} = indM(p);
					index_cell{q} = indM(q);
					index_cell{r} = [indM(r) - 1, indM(r)];
					assert(indM(r) - 1 >= 1, ...
						'PointSrcM should not be at boundary of %s-axis.', char(r));
					dlp = grid3d.dl{r, GK.dual}(index_cell{p});  % one element
					dlr = grid3d.dl{r, GK.dual}(index_cell{r});  % two elements
					dS = dlp .* dlr;
					Jw_patch = [I, -I] ./ dS;
				else
					assert(w_axis == r);
					% Assign Jr.
					index_cell{p} = indM(p);
					index_cell{q} = [indM(q) - 1, indM(q)];
					index_cell{r} = indM(r);
					assert(indM(q) - 1 >= 1, ...
						'PointSrcM should not be at boundary of %s-axis.', char(q));
					dlp = grid3d.dl{r, GK.dual}(index_cell{p});  % one element
					dlq = grid3d.dl{q, GK.dual}(index_cell{q});  % two elements
					dS = dlp .* dlq;
					Jw_patch = [-I, I] ./ dS;
					Jw_patch = Jw_patch.';
				end
				Jw_patch = ipermute(Jw_patch, int([q r p]));
			end
		end		
	end
end
