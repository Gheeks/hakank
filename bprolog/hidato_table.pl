/*

  Hidato puzzle in B-Prolog.

  http://www.shockwave.com/gamelanding/hidato.jsp
  http://www.hidato.com/
 
  """
  Puzzles start semi-filled with numbered tiles.
  The first and last numbers are circled.
  Connect the numbers together to win. Consecutive
  number must touch horizontally, vertically, or
  diagonally.
  """

  This version use the table constraint.

  Model created by Hakan Kjellerstrand, hakank@gmail.com
  See also my B-Prolog page: http://www.hakank.org/bprolog/

*/

% Reporting both time and backtracks
time2(Goal):-
        cputime(Start),
        statistics(backtracks, Backtracks1),
        call(Goal),
        statistics(backtracks, Backtracks2),
        cputime(End),
        T is (End-Start)/1000,
        Backtracks is Backtracks2 - Backtracks1,
        format('CPU time ~w seconds. Backtracks: ~d\n', [T, Backtracks]).


go :-
        time2(solve(1)).

go2 :-
        NumProblems = 8,
        foreach(P in 1..NumProblems, time2(solve(P))).

go3 :-
        time2(solve(7)).

go4 :-
        time2(solve(8)).

solve(Problem) :-
        format("\nProblem ~d\n", [Problem]),
        problem(Problem,X),
        hidato(X).


hidato(X) :-

        N @= X^length,

        % decision variables
        % array_to_list(X,XVar),
        XVar @= [X[I,J] : I in 1..N, J in 1..N],
        XVar :: 1..N*N,

        % Valid connections, used by the table constraint
        Connections @= [(I1,J1,I2,J2) :
                       I1 in 1..N, J1 in 1..N, 
                        I2 in 1..N, J2 in 1..N,
                        (abs(I1-I2) =< 1,
                         abs(J1-J2) =< 1,
                         (I1 \=I2; J1 \= J2)
                        )
                       ],

        % place all integers from 1..N*N
        % alldistinct(XVar),
        alldifferent(XVar),
        foreach(K in 1..(N*N)-1,
                [I1,J1,I2,J2,K2,Offset1,Offset2],
                [ac(AllConn,[]),ac(Offsets,[])],
                (
                    K2 is K+1,
                    [I1,J1,I2,J2] :: 1..N,
                    % [(I1,J1,I2,J2)] in Connections,
                    [Offset1,Offset2] :: 1..N*N,
                    Offset1 #= (I1-1)*N+J1,
                    element(Offset1,XVar,K),
                    Offset2 #= (I2-1)*N+J2,
                    element(Offset2,XVar,K2),
                    AllConn^1 = [(I1,J1,I2,J2)|AllConn^0],
                    Offsets^1 = [[Offset1,Offset2]|Offsets^0]
                )
               ),

        % Collect for the table constraint
        AllConn in Connections,

        % term_variables([XVar,AllConn,Offsets],Vars),
        % labeling([ff],Vars),

        % faster labeling
        term_variables([Offsets,XVar,AllConn],Vars),
        labeling([ff],Vars), 
        % labeling([ff,down],Vars), % 7 is faster but 8 is much slower

        pretty_print(X).


pretty_print(X) :-
        N @= X^length,
        foreach(I in 1..N,
                (foreach(J in 1..N, [XX], (XX @= X[I,J], format("~3d ", XX) )), nl)
        ),nl.        



%
% Problems
%


% problem(0, [[_,_,_],
%             [_,_,_],
%             [_,_,_]]).


problem(0, [[6,7,9],
            [5,2,8],
            [1,4,3]]).



% Simple problem
%
% solution:
%   6 7 9
%   5 2 8
%   1 4 3
% 
problem(1, [[6,_,9],
            [_,2,8],
            [1,_,_]]).



problem(2, []([]( _,44,41, _, _, _, _),
              []( _,43, _,28,29, _, _),
              []( _, 1, _, _, _,33, _),
              []( _, 2,25, 4,34, _,36),
              [](49,16, _,23, _, _, _),
              []( _,19, _, _,12, 7, _),
              []( _, _, _,14, _, _, _))). 



% Problems from the book:
% Gyora Bededek: "Hidato: 2000 Pure Logic Puzzles"

% problem 1 (Practice)
problem(3, []([](_, _,20, _, _),
              [](_, _, _,16,18),
              [](22, _,15, _, _),
              [](23, _, 1,14,11),
              [](_,25, _, _,12))).
              


% problem 2 (Practice)
problem(4, []([](_, _, _, _,14),
              [](_,18,12, _, _),
              [](_, _,17, 4, 5),
              [](_, _, 7, _, _),
              [](9, 8,25, 1, _))).


% problem 3 (Beginner)
problem(5, []([]( _,26, _, _, _,18),
              []( _, _,27, _, _,19),
              [](31,23, _, _,14, _),
              []( _,33, 8, _,15, 1),
              []( _, _, _, 5, _, _),
              [](35,36, _,10, _, _))).



% Problem 15 (Intermediate)
problem(6,[]([](64, _, _, _, _, _, _, _),
             []( 1,63, _,59,15,57,53, _),
             []( _, 4, _,14, _, _, _, _),
             []( 3, _,11, _,20,19, _,50),
             []( _, _, _, _,22, _,48,40),
             []( 9, _, _,32,23, _, _,41),
             [](27, _, _, _,36, _,46, _),
             [](28,30, _,35, _, _, _, _))).


% Problem 156 (Master)
% (This is harder to solve than the 12x12 prolem 188 below...%)
problem(7, []([](88, _, _,100, _, _,37,_, _,34),
              []( _,86, _,96,41, _, _,36, _, _),
              []( _,93,95,83, _, _, _,31,47, _),
              []( _,91, _, _, _, _, _,29, _, _),
              [](11, _, _, _, _, _, _,45,51, _),
              []( _, 9, 5, 3, 1, _, _, _, _, _),
              []( _,13, 4, _, _, _, _, _, _, _),
              [](15, _, _,25, _, _,54,67, _, _),
              []( _,17, _,23, _,60,59, _,69, _),
              [](19, _,21,62,63, _, _, _, _, _))).


% Problem 188 (Genius)
problem(8, []([](  _,  _,134,  2,  4,  _,  _,  _,  _,  _,  _,  _),
              [](136,  _,  _,  1,  _,  5,  6, 10,115,106,  _,  _),
              [](139,  _,  _,124,  _,122,117,  _,  _,107,  _,  _),
              [](  _,131,126,  _,123,  _,  _, 12,  _,  _,  _,103),
              [](  _,  _,144,  _,  _,  _,  _,  _, 14,  _, 99,101),
              [](  _,  _,129,  _, 23, 21,  _, 16, 65, 97, 96,  _),
              []( 30, 29, 25,  _,  _, 19,  _,  _,  _, 66, 94,  _),
              []( 32,  _,  _, 27, 57, 59, 60,  _,  _,  _,  _, 92),
              [](  _, 40, 42,  _, 56, 58,  _,  _, 72,  _,  _,  _),
              [](  _, 39,  _,  _,  _,  _, 78, 73, 71, 85, 69,  _),
              []( 35,  _,  _, 46, 53,  _,  _,  _, 80, 84,  _,  _),
              []( 36,  _, 45,  _,  _, 52, 51,  _,  _,  _,  _, 88))).
