% Two cliques: (1,2,4) and (3, 5)
%  % 1  2  3  4  5
%    1, 1, 0, 1, 0,  % 1  
%    1, 1, 0, 1, 0,  % 2
%    0, 0, 1, 0, 1,  % 3 
%    1, 1, 0, 1, 0,  % 4
%    0, 0, 1, 0, 1   % 5
e(1, 1).
e(1, 2).
e(1, 4).
e(2, 1).
e(2, 2).
e(2, 4).
e(3, 3).
e(3, 5).
e(4, 1).
e(4, 2).
e(4, 4).
e(5, 3).
e(5, 5).

#const n = 2. % minimum size of clique
