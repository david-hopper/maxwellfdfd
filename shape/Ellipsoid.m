%% Ellipsoid
% Concrete subclass of <Shape.html |Shape|> representing an ellipsoid.

%%% Description
% |Ellipsoid| represents the shape of an ellipsoid.  The three axes of the
% ellipsoid should be aligned with the axes of the Cartesian coordinate system.

%%% Construction
%  shape = Ellipsoid(center, semiaxes)
%  shape = Ellipsoid(center, semiaxes, dl_max)

% *Input Arguments*
%
% * |center|: center of the ellipsoid in the format of |[x y z]|.
% * |semiaxes|: semiaxes of the ellipse in the format of |[a b c]|.
% * |dl_max|: maximum grid size allowed in the ellipsoid.  It can be either |[dx
% dy dz]| or a single real number |dl| for |dx = dy = dz|.  If unassigned,
% |dl_max = Inf| is used.

%%% Example
%   % Create an instance of Ellipsoid.
%   shape = Ellipsoid(Axis.z, [0 0 0], [100 50 50]);
%
%   % Use the constructed shape in maxwell_run().
%   [E, H] = maxwell_run({INITIAL ARGUMENTS}, 'OBJ', {'vacuum', 'none', 1.0}, shape, {REMAINING ARGUMENTS});

%%% See Also
% <Sphere.html |Sphere|>, <CircularCylinder.html |CircularCylinder|>,
% <EllipticCylinder.html |EllipticCylinder|>, <Shape.html |Shape|>,
% <maxwell_run.html |maxwell_run|>

classdef Ellipsoid < Shape

	methods
        function this = Ellipsoid(center, semiaxes, dl_max)
			chkarg(istypesizeof(center, 'real', [1, Axis.count]), ...
				'"center" should be length-%d row vector with real elements.', Axis.count);

			chkarg(istypesizeof(semiaxes, 'real', [1, Axis.count]) && all(semiaxes > 0), ...
				'"semiaxes" should be length-%d row vector with positive elements.', Axis.count);
			
			bound = [center - semiaxes; center + semiaxes];
			bound = bound.';
			
			% The level set function is basically 1 - norm((r-center)./semiaxes)
			% but it is vectorized, i.e., modified to handle r = [x y z] with
			% column vectors x, y, z.
			function level = lsf(r)
				chkarg(istypesizeof(r, 'real', [0, Axis.count]), ...
					'"r" should be matrix with %d columns with real elements.', Axis.count);
				N = size(r, 1);
				c_vec = repmat(center, [N 1]);
				s_vec = repmat(semiaxes, [N 1]);
				x = (r - c_vec) ./ s_vec;
				level = 1 - sqrt(sum(x.*x, 2));
			end
			
			lprim = cell(1, Axis.count);
			for w = Axis.elems
				lprim{w} = bound(w,:);
			end
			
			if nargin < 3  % no dl_max
				super_args = {lprim, @lsf};
			else
				super_args = {lprim, @lsf, dl_max};
			end
			
			this = this@Shape(super_args);
		end
	end	
end

