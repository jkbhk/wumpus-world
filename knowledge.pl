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
       hasarrow/0,
       dead/1,
       hascoin/1,
       shootArrow/0
]).


hasarrow :-
	shootArrow -> false ; true.


reborn :-
	retractall(wumpus(_,_)),retractall(dead(_)),
	retractall(confundus(_,_)),
	retractall(reposition(_)),retractall(current(_,_,_)),
	retractall(shootArrow),
	retractall(stench(_,_)),retractall(tingle(_,_)),
	retractall(glitter(_,_)),retractall(wall(_,_)),
	retractall(visited(_,_)),assertz(visited(0,0)),
	retractall(current(_,_,_)),assertz(current(0,0,rnorth)).

/* reposition:
The Agent is randomly relocated to a safe location in the Wumpus World.
The relative position is reset to (0,0) and relative orientation is
reset to become the Relative North. All memory of previous steps and
sensory readings is lost, except the fact of existence of uncollected
coins, whether the Wumpus is alive and whether the Agent has the
arrow.*/
reposition([on,_,_,_,_,_]) :-
	retractall(visited(_,_)),retractall(wumpus(_,_)),
	retractall(confundus(_,_)),retractall(tingle(_,_)),
	retractall(glitter(_,_)),retractall(stench(_,_)),
	retractall(safe(_,_)),retractall(wall(_,_)),
	retractall(current(_,_,_)),assertz(current(0,0,rnorth)).
        % reset relative positive (0,0), relative orientation is north


% visited: if in databse, return true, else return false (for every
% move, add visited to the database.
% wumpus: if got stench, set the
% squares (X,Y+1),(X,Y-1),(X+1,Y),(X-1,Y) as true same as tingle,
% glitter: if i move and got glitter, pick up coin
% wall: if i move and hit a wall, receive a bump

% Confounded - Stench - Tingle - Glitter - Bump - Scream

clearData(X,Y) :-
	wumpus(X,Y), confundus(X,Y) -> retract(wumpus(X,Y)),retract(confundus(X,Y));
	wumpus(X,Y), \+confundus(X,Y) -> retract(wumpus(X,Y));
	\+wumpus(X,Y), confundus(X,Y) -> retract(confundus(X,Y)).


advance :-
	current(X,Y,D),
	D == rnorth,
        NewY is Y + 1,
	retractall(current(_,_,_)),
	assertz(current(X,NewY,D)),
	assertz(visited(X,NewY)).

advance :-
	current(X,Y,D),
	D == rsouth,
	NewY is Y - 1,
	retractall(current(_,_,_)),
	assertz(current(X,NewY,D)),
	assertz(visited(X,NewY)).

advance :-
	current(X,Y,D),
	D == reast,
	NewX is X + 1,
	retractall(current(_,_,_)),
	assertz(current(NewX,Y,D)),
	assertz(visited(NewX,Y)).

advance :-
	current(X,Y,D),
	D == rwest,
	NewX is X - 1,
	retractall(current(_,_,_)),
	assertz(current(NewX,Y,D)),
	assertz(visited(NewX,Y)).

checkStench(STENCH) :-
	STENCH == on,
	current(X,Y,_),
	assertz(stench(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	assertz(wumpus(W,Y)), %left
	assertz(wumpus(E,Y)), %right
	assertz(wumpus(X,N)), %top
	assertz(wumpus(X,S)). %bottom

checkConfounded(CONFOUNDED) :-
	CONFOUNDED == on,
	reposition([on,_,_,_,_,_]).

checkTingle(TINGLE) :-
	TINGLE == on,
	current(X,Y,_),
	assertz(tingle(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	assertz(confundus(W,Y)), %left
	assertz(confundus(E,Y)), %right
	assertz(confundus(X,N)), %top
	assertz(confundus(X,S)). %bottom

checkGlitter(GLITTER) :-
	GLITTER == on,
	current(X,Y,_),
	assertz(glitter(X,Y)).


pickup:-
	assertz(hascoin(agent)),
	retractall(glitter(_,_)).


move(turnleft,[_,_,_,_,_,_]) :-
	current(A,B,rnorth),
	retractall(current(_,_,_)),
	assertz(current(A,B,rwest));

	current(A,B,rwest),
	retractall(current(_,_,_)),
	assertz(current(A,B,rsouth));

	current(A,B,rsouth),
	retractall(current(_,_,_)),
	assertz(current(A,B,reast));

	current(A,B,reast),
	retractall(current(_,_,_)),
	assertz(current(A,B,rnorth)).


move(turnright,[_,_,_,_,_,_]) :-
	current(A,B,rnorth),
	retractall(current(_,_,_)),
	assertz(current(A,B,reast));

	current(A,B,rwest),
	retractall(current(_,_,_)),
	assertz(current(A,B,rnorth));

	current(A,B,rsouth),
	retractall(current(_,_,_)),
	assertz(current(A,B,rwest));

	current(A,B,reast),
	retractall(current(_,_,_)),
	assertz(current(A,B,rsouth)).


%When agent step into portal, do reposition
/*move(A,[Confounded,_,_,_,_,_]) :-
	A == moveforward,
	Confounded == on,
	reposition([on,_,_,_,_,_]). */

%When agent senses stench, set possible wumpus positions
move(A,[Confounded,Stench,Tingle,Glitter,Bump,_]) :-
	A == moveforward,
	Bump == off,
	advance,
	checkStench(Stench),
        checkConfounded(Confounded),
	checkTingle(Tingle),
        checkGlitter(Glitter).

move(A,[_,_,_,_,Bump,_]) :-
	A == moveforward,
	Bump == on,
	current(X,Y,D),
	(
	% remove wumpus/confundus in the wall based on D
	   (
	   D == rnorth,
	   WallY is Y + 1,
	   assertz(wall(X,WallY)),
	   clearData(X,WallY) );

	    (
	   D == rsouth,
	   WallY is Y - 1,
	   assertz(wall(X,WallY)),
	   clearData(X,WallY) );

        (
	    D == reast,
	    WallX is X + 1,
	    assertz(wall(WallX,Y)),
	    clearData(WallX,Y) );

	(
	    D == rwest,
	    WallX is X - 1,
	    assertz(wall(WallX,Y)),
	    clearData(WallX,Y) )

	).

move(A,[_,_,_,_,_,_]) :-
	A == pickup,
	pickup.

move(A,[_,_,_,_,_,Scream]) :-
     A == shoot, assertz(shootArrow),
     Scream == on ->
     ( assertz(dead(wumpus)),
     retractall(wumpus(_,_)),
     retractall(stench(_,_))).


%When agent senses tingle, set possible confundus portal positions
/*move(A,[_,_,Tingle,_,_,_]) :-
	A == moveforward,
	Tingle == on,
	current(X,Y,_),
	assertz(safe(X,Y)),
	assertz(tingle(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	assertz(confundus(W,Y)), %left
	assertz(confundus(E,Y)), %right
	assertz(confundus(X,N)), %top
	assertz(confundus(X,S)). %bottom */


%When agent senses glitter, pickup coin
/*move(A,[_,_,_,Glitter,_,_]) :-
	A == moveforward,
	Glitter == on,
	current(X,Y,_),
	assertz(safe(X,Y)),
	assertz(glitter(X,Y)), %initially there was glitter
	move(pickup,[_,_,_,Glitter,_,_]),
	retract(glitter(X,Y)). %once u pick the coin, glitter is gone*/


/*move(pickup,[_,_,_,Glitter,_,_]) :-
	Glitter == on,
	assertz(hascoin(agent)). */



%When agent move forward and collides with a wall
/*move(A,[_,_,_,_,Bump,_]) :-
	A == moveforward,
	Bump == on,
	current(X,Y,_),
	assertz(safe(X,Y)),
	assertz(wall(X,Y)).*/

/*move(A,[_,_,_,_,_,Scream]) :-
	A == shoot,
	Scream == on,
	assertz(dead(wumpus)),
	retractall(wumpus(_,_)),
	retractall(stench(_,_)),
	write('Wumpus is dead') , nl ,
	write('Agent has 0 arrows left'). */



/* Agent step on cell inhabited by wumpus:
Relative position reset occurs, as with the case of stepping into a
Confundus Portal, to prepare for a new game. All memory of previous
steps and sensory reading is lost without exceptions, the arrow is
returned to the Agent. */

/*wall(X,Y) :-
	move(moveforward,[_,_,_,_,on,_])->
	assertz(wall(X,Y)). */

/*glitter(X,Y) :-
	move(moveforward,[_,_,_,on,_,_])->
	assertz(glitter(X,Y)), %initially there was glitter
	move(pickup,[_,_,_,_,_,_]),
	retract(glitter(X,Y)). %once u pick the coin, glitter is gone*/

/*stench(X,Y) :-
	move(moveforward,[_,on,_,_,_,_])->
	assertz(stench(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	assertz(wumpus(W,Y)), %left
	assertz(wumpus(E,Y)), %right
	assertz(wumpus(X,N)), %top
	assertz(wumpus(X,S)). %bottom */

/*tingle(X,Y) :-
	move(moveforward,[_,_,on,_,_,_])->
	assertz(tingle(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	assertz(confundus(W,Y)), %left
	assertz(confundus(E,Y)), %right
	assertz(confundus(X,N)), %top
	assertz(confundus(X,S)). %bottom*/




safe(X,Y) :-
	\+wumpus(X,Y),
	\+confundus(X,Y).


/*explore(L) :-
	current(X,Y,_),
	NewY is Y + 1,
	safe(X,NewY),
	L = moveforward;

	current(X,Y,_),
	NewY is Y - 1,
	safe(X,NewY);

	current(X,Y,_),
	NewX is X + 1,
	safe(NewX,Y);

	current(X,Y,_),
	NewX is X - 1,
	safe(NewX,Y),

	explore(L).*/








