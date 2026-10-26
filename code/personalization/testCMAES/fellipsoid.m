function f = fellipsoid(x)
    x = x(:);
    n = length(x);
    if n == 1
        f = x^2;
    else
        f = sum((10.^(6*(0:n-1)/(n-1))) .* x'.^2);
    end
end