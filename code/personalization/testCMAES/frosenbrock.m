function f = frosenbrock(x)
    x = x(:);
    n = length(x);
    f = sum(100*(x(2:n) - x(1:n-1).^2).^2 + (1 - x(1:n-1)).^2);
end