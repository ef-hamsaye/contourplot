function Z_extrapolation = extrapolateThickness(F, X_extrapolation, Y_extrapolation, x_boundaries, y_boundaries)
    num_points = size(X_extrapolation, 1) * size(X_extrapolation, 2);
    Z_extrapolation = NaN(size(X_extrapolation));
    parfor i = 1:num_points
        x = X_extrapolation(i);
        y = Y_extrapolation(i);
        if inpolygon(x, y, x_boundaries, y_boundaries)
            Z_extrapolation(i) = F(x, y);
        end
    end
end