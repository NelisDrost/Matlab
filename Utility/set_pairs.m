function C = set_pairs(A, B)
% Returns index pairs into sets A & B, such that
% A(C(i,1)) == B(C(i,2))

[AA, AI] = sort(A);
[BB, BI] = sort(B);

SX = setxor(AA, BB);

AI(ismember(AA,SX)) = [];
AA(ismember(AA,SX)) = [];

BI(ismember(BB,SX)) = [];
BB(ismember(BB,SX)) = [];

[~, IIA, IIB] = intersect(AA,BB);

C = [];
A_Bounds = [IIA [IIA(2:end)-1; length(AA)]];
B_Bounds = [IIB [IIB(2:end)-1; length(BB)]];
for i = 1:size(A_Bounds,1)
    C = [C; list_permute((A_Bounds(i,1):A_Bounds(i,2))',(B_Bounds(i,1):B_Bounds(i,2))')];
end

C = sortrows([AI(C(:,1))', BI(C(:,2))']);