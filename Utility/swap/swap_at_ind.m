function [a, b] = swap_at_ind(a, b, ind)

[a(ind), b(ind)] = swap(a(ind), b(ind));