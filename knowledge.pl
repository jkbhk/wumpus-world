say_hi :-
	write('What is your name?'),
	read(X),
	write('Hi '),
	write(X).

check_equal(A,B) :-
	A == B ->
	write("A and B are equal") , nl,
	write("hello") , !;

	A >= B ->
	write("A greater than B") ,!;

	A < B ->
	write("A lesser than B") ,! .

/*:- abolish(visited/2).
:- abolish(wumpus/2).
:- abolish(confundus/2).
:- abolish(tingle/2).
:- abolish(glitter/2).
:- abolish(stench/2).
:- abolish(safe/2).
:- abolish(wall/2).
:- abolish(move/2).
:- abolish(reposition/1).
:- abolish(current/3).
:- abolish(explore/1). */

:- dynamic([
       visited/2,
       wumpus/2,
       confundus/2,
       tingle/2,
       glitter/2,
       stench/2,
       safe/2,
       wall/2,
       move/2,
       reposition/1,
       current/3,
       explore/1,
       reborn/0,
       hasarrow/0
]).


/* hasarrow :-
	\+move(shoot,_),
	write('Agent still has arrow').
*/


reborn :-
	write('What is your name?'),
	read(X),
	write('Hi '),
	write(X).


% visited: if in databse, return true, else return false (for every
% move, add visited to the database.
% wumpus: if got stench, set the
% squares (X,Y+1),(X,Y-1),(X+1,Y),(X-1,Y) as true same as tingle,
% glitter: if i move and got glitter, pick up coin
% wall: if i move and hit a wall, receive a bump

move(moveforward,bump).

wall(X,Y) :-
	move(moveforward,bump),
	assertz(wall(X,Y)).












