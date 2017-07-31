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
        time2(solve(6)).


go2 :-
        % NumProblems = 8,
        foreach(P in [1,2,3,4,5,6,8], time2(solve(P))).


solve(Problem) :-
        format("\nProblem ~d\n", [Problem]),
        problem(Problem,X),
        hidato(X).


hidato(X) :-

        N @= X^length,
        % decision variables
        array_to_list(X,XList),
        XList :: 1..N*N,

        % Valid connections, used by the table constraint
        Connections @= [(I1,J1,I2,J2) :
                       I1 in 1..N, J1 in 1..N, 
                        I2 in 1..N, J2 in 1..N,
                        (abs(I1-I2) =< 1,
                         abs(J1-J2) =< 1,
                         (I1 \=I2; J1 \= J2)
                        )
                       ],
        % place all integers from 1..r*c
        alldifferent(XList),
        % propagations)
        NN1 is (N*N)-1,

        foreach(K in 1..NN1,[I,J,IJ,IA_JB,K1,A,B,IA,JB],
                [ac(Extras,[]),ac(Connect,[])],
                
                (% define temporary variables for finding
                 % the index of this and the next number (K)
                 I :: 1..N, % index I
                 J :: 1..N, % index J
                 A :: -1..1, % offset from K's position
                 B :: -1..1, % ibid

                 % needed for element
                 IA #= I+A,
                 JB #= J+B,
                 
                 % some extra constraints
                 IA #>= 1,JB #>= 1,
                 IA #=< N,JB #=< N,
                 abs(A)+abs(B) #>= 1, % both A and B cannot be 0, i.e. it
                                      % must be a move
                                      % 1. First: fix this k, i.e.
                                      % K #= X[I,J], % don't work (instantiation fault)
                 IJ #= (I-1)*N + J,
                 element(IJ, XList, K),
                 

                 % 2. Then, find the position of the next value, i.e.
                 % K+1 #= X[I+A,J+B], % don't work
                 IA_JB #= (I-1+A)*N + J+B,
                 K1 is K+1,
                 element(IA_JB, XList, K1),

                 Extras^1 = [[IJ,IA_JB,A,B]|Extras^0],
                 Connect^1 = [(I,J,IA,JB)|Connect^0]
                )
               ),
        Connect in Connections,

        term_variables([X,Extras,Connect],Vars),
        labeling([inout,down],Vars),
        % labeling([ff],Vars),

        pretty_print(X).


pretty_print(X) :-
        N @= X^length,
        foreach(I in 1..N,
                (foreach(J in 1..N, [XX],
                         (
                         XX @= X[I,J],
                         format("~3d ", XX)
                         ))
                , nl
                )
        ),nl.        



%
% Problems
%


% Simple problem
%
% solution:
%   6 7 9
%   5 2 8
%   1 4 3
% 
problem(1, []([](6,_,9),
              [](_,2,8),
              [](1,_,_))).



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



% Variable selection
selection([backward,constr,degree,ff,ffc,forward,inout,leftmost,max,min]).

% Value selection
choice([down,updown,split,reverse_split]).
