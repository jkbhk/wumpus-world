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
       shootArrow/0,
       markWumpusIfSuspicious/2,
       locationFound/1,
       uncollectedCoins/1,
       tried/3,
       safeToBacktrack/2,
       goHome/2,
       recursiveBackHome/4,
	   state/1,
	   surrounded/2,
	   path/2,
	   unexplored/2,
	   explored/2
]).

hasarrow :-
	shootArrow -> false ; true.


reborn :-
	retractall(wumpus(_,_)),retractall(dead(_)),
	retractall(confundus(_,_)),retractall(current(_,_,_)),
	retractall(shootArrow),
	retractall(stench(_,_)),retractall(tingle(_,_)),
	retractall(glitter(_,_)),retractall(wall(_,_)),
	retractall(visited(_,_)),assertz(visited(0,0)),
	retractall(current(_,_,_)),assertz(current(0,0,rnorth)),
	retractall(safe(_,_)), assertz(safe(0,0)),
	retractall(locationFound(_)),
	retractall(safeToBacktrack(_,_)),
	retractall(hascoin(_)),
	retractall(goHome(_,_)).


reposition([_,_,_,_,_,_]) :-
	retractall(wumpus(_,_)),
	retractall(confundus(_,_)), retractall(tingle(_,_)),
	retractall(stench(_,_)),
	retractall(visited(_,_)), assertz(visited(0,0)),
	retractall(safe(_,_)), assertz(safe(0,0)),
	retractall(wall(_,_)),
	retractall(current(_,_,_)),assertz(current(0,0,rnorth)),
	retractall(goHome(_,_)),retractall(safeToBacktrack(_,_)).
        % reset relative positive (0,0), relative orientation is north



% visited: if in databse, return true, else return false (for every
% move, add visited to the database.
% wumpus: if got stench, set the
% squares (X,Y+1),(X,Y-1),(X+1,Y),(X-1,Y) as true same as tingle,
% glitter: if i move and got glitter, pick up coin
% wall: if i move and hit a wall, receive a bump

% Confounded - Stench - Tingle - Glitter - Bump - Scream
clearData(X,Y) :-
	wumpus(X,Y), confundus(X,Y) -> retract(wumpus(X,Y)),
	retract(confundus(X,Y));
	wumpus(X,Y), \+confundus(X,Y) -> retract(wumpus(X,Y));
	\+wumpus(X,Y), confundus(X,Y) -> retract(confundus(X,Y)).


advance :-
	current(X,Y,D),
	D == rnorth,
	assertz(safeToBacktrack(X,Y)),
	assertz(path(X,Y)),
        NewY is Y + 1,
	(  ( \+visited(X,NewY) ,assertz(goHome(X,Y)));true ),
	retractall(current(_,_,_)),
	assertz(current(X,NewY,D)),
	assertz(visited(X,NewY)).

advance :-
	current(X,Y,D),
	D == rsouth,
	assertz(safeToBacktrack(X,Y)),
	assertz(path(X,Y)),
	NewY is Y - 1,
	(   (\+visited(X,NewY) ,assertz(goHome(X,Y)));true ),
	retractall(current(_,_,_)),
	assertz(current(X,NewY,D)),
	assertz(visited(X,NewY)).

advance :-
	current(X,Y,D),
	D == reast,
	assertz(safeToBacktrack(X,Y)),
	assertz(path(X,Y)),
	NewX is X + 1,
	(  ( \+visited(NewX,Y) ,assertz(goHome(X,Y)));true ),
	retractall(current(_,_,_)),
	assertz(current(NewX,Y,D)),
	assertz(visited(NewX,Y)).

advance :-
	current(X,Y,D),
	D == rwest,
	assertz(safeToBacktrack(X,Y)),
	assertz(path(X,Y)),
	NewX is X - 1,
	(  ( \+visited(NewX,Y) ,assertz(goHome(X,Y)));true ),
	retractall(current(_,_,_)),
	assertz(current(NewX,Y,D)),
	assertz(visited(NewX,Y)).


confirmNoWumpus(X,Y) :-
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(( visited(X, N),\+stench(X,N));
	( visited(X, S),\+stench(X,S));
	( visited(E, Y),\+stench(E,Y));
	( visited(W, Y),\+stench(W,Y))).

confirmNoPortal(X,Y) :-
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(( visited(X, N),\+tingle(X,N));
	( visited(X, S),\+tingle(X,S));
	( visited(E, Y),\+tingle(E,Y));
	( visited(W, Y),\+tingle(W,Y))).



markWumpusIfSuspicious(X,Y) :-
	\+locationFound(wumpus), \+confirmNoWumpus(X,Y),
	\+safe(X,Y),assertz(wumpus(X,Y))
	,false.

markPortalIfSuspicious(X,Y) :-
	\+confirmNoPortal(X,Y) , \+safe(X,Y) ,
	assertz(confundus(X,Y))
	,false.



checkStench(STENCH) :-
	STENCH == on,
	current(X,Y,_),
	assertz(stench(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(
	markWumpusIfSuspicious(W,Y); %left
	markWumpusIfSuspicious(E,Y); %right
	markWumpusIfSuspicious(X,N); %top
	markWumpusIfSuspicious(X,S) %bottom
	).


checkConfounded([CONFOUNDED,_,_,_,_,_]) :-
	CONFOUNDED == on,
	reposition([CONFOUNDED,_,_,_,_,_]).


checkTingle(TINGLE) :-
	TINGLE == on,
	current(X,Y,_),
	assertz(tingle(X,Y)),
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(
        (retractall(confundus(X,Y)) , false);
	markPortalIfSuspicious(W,Y); %left
	markPortalIfSuspicious(E,Y); %right
	markPortalIfSuspicious(X,N); %top
	markPortalIfSuspicious(X,S) %bottom
	).



checkGlitter(GLITTER) :-
	GLITTER == on,
	current(X,Y,_),
	assertz(glitter(X,Y)).


pickup(X,Y) :-
	assertz(hascoin(agent)),
	retractall(glitter(X,Y)).


handleTurnRight(A,B,D) :-
	D == rnorth,
	retractall(current(_,_,_)),
	assertz(current(A,B,reast)).

handleTurnRight(A,B,D) :-
	D == reast,
	retractall(current(_,_,_)),
	assertz(current(A,B,rsouth)).

handleTurnRight(A,B,D) :-
	D == rsouth,
	retractall(current(_,_,_)),
	assertz(current(A,B,rwest)).

handleTurnRight(A,B,D) :-
	D == rwest,
	retractall(current(_,_,_)),
	assertz(current(A,B,rnorth)).


handleTurnLeft(A,B,D) :-
	D == rnorth,
	retractall(current(_,_,_)),
	assertz(current(A,B,rwest)).

handleTurnLeft(A,B,D) :-
	D == rwest,
	retractall(current(_,_,_)),
	assertz(current(A,B,rsouth)).

handleTurnLeft(A,B,D) :-
	D == rsouth,
	retractall(current(_,_,_)),
	assertz(current(A,B,reast)).

handleTurnLeft(A,B,D) :-
	D == reast,
	retractall(current(_,_,_)),
	assertz(current(A,B,rnorth)).


move(turnleft,[_,_,_,_,_,_]) :-
	current(X,Y,D),
	handleTurnLeft(X,Y,D).

move(turnright,[_,_,_,_,_,_]) :-
	current(X,Y,D),
	handleTurnRight(X,Y,D).


move(A,[Confounded,Stench,Tingle,Glitter,Bump,_]) :-
	A == moveforward,
	Bump == off,
	advance,
	current(X,Y,_),
	assertz(safe(X,Y)),
	(
		(checkVerySafe([Confounded,Stench,Tingle,Glitter,Bump,_]) , false);
		(checkStench(Stench) , false);
		(checkTingle(Tingle) , false);
		(checkGlitter(Glitter) , false);
		(checkConfounded([Confounded,Stench,Tingle,Glitter,Bump,_])
		, false)
	).

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

move(A,[_,_,_,Glitter,_,_]) :-
	A == pickup, Glitter = on,
	current(X,Y,_),
	pickup(X,Y).

move(A,[_,_,_,_,_,Scream]) :-
     A == shoot, hasarrow, assertz(shootArrow),
     Scream == on ->
     ( assertz(dead(wumpus)),
     retractall(wumpus(_,_)),
     retractall(stench(_,_))).

checkVerySafe([_,Stench,Tingle,_,_,_]) :-
	 Stench == off,
	 Tingle == off,
	 current(X,Y,_),
	 (retractall(confundus(X,Y)) ; true),
	 (retractall(wumpus(X,Y)) ; true),
	 markAdjacentSafe(X,Y).


markAdjacentSafe(X,Y) :-
	N is Y + 1,
	S is Y - 1,
	E is X + 1,
	W is X - 1,
	assertz(safe(X,N)),assertz(unexplored(X,N)), (retract(wumpus(X,N)) ; retract(confundus(X,N)) ; true),
	assertz(safe(X,S)),assertz(unexplored(X,S)), (retract(wumpus(X,S)) ; retract(confundus(X,S)) ; true),
	assertz(safe(E,Y)),assertz(unexplored(E,Y)), (retract(wumpus(E,Y)) ; retract(confundus(E,Y)) ; true),
	assertz(safe(W,Y)),assertz(unexplored(W,Y)),(retract(wumpus(W,Y)) ; retract(confundus(W,Y)) ; true),
	findWumpus.

findWumpus :-
	aggregate_all(count, wumpus(_,_), WumpusCount),
	WumpusCount == 1,
	assertz(locationFound(wumpus)).


% case 1: no inferred safe edge
% case 2: got iferred sage edge
% case 3: no unvisited safe edge
%

%recursively go home if goHome(X,Y) is in the knowledge base
%once i move back to that cell, retract from knowledge base
%recursiveBackHome(_,_,_) :-
%goHome(0,0).



decide(X,Y,D,L) :-
	N is Y + 1, %top
	E is X + 1, %right
	S is Y - 1, %bottom
	W is X - 1, %left
    (
		( %check top
			( unexplored(X,N),\+explored(X,N),\+path(X,N),\+wall(X,N) ),
			(		
				( D == rnorth, assertz(explored(X,N)), L = [moveforward]);
				( D == rsouth, assertz(explored(X,N)), L = [turnleft,turnleft,moveforward]);
				( D == reast, assertz(explored(X,N)), L = [turnleft,moveforward]);
				( D == rwest, assertz(explored(X,N)), L = [turnright,moveforward])
			)
		);

		( %check right
			( unexplored(E,Y),\+explored(E,Y),\+path(E,Y),\+wall(E,Y) ),
			(            
				( D == rnorth, assertz(explored(E,Y)),L = [turnright,moveforward]);
				( D == rsouth, assertz(explored(E,Y)),L = [turnleft,moveforward]);
				( D == reast,  assertz(explored(E,Y)),L = [moveforward]);
				( D == rwest, assertz(explored(E,Y)), L = [turnright,turnright,moveforward])
			)
		);

		( %check bottom
			( unexplored(X,S),\+explored(X,S),\+path(X,S),\+wall(X,S) ),
			(        
			 	( D == rnorth, assertz(explored(X,S)), L = [turnright,turnright,moveforward]);
				( D == rsouth, assertz(explored(X,S)), L = [moveforward]);
				( D == reast, assertz(explored(X,S)), L = [turnright,moveforward]);
				( D == rwest, assertz(explored(X,S)), L = [turnleft,moveforward])
			)
		);

		( %check left
			( unexplored(W,Y),\+explored(W,Y), \+path(W,Y), \+wall(W,Y) ),
			(
					( D == rnorth, assertz(explored(W,Y)), L = [turnleft,moveforward]);
					( D == rsouth, assertz(explored(W,Y)), L = [turnright,moveforward]);
					( D == reast, assertz(explored(W,Y)), L = [turnright,turnright,moveforward]);
					( D == rwest ,assertz(explored(W,Y)), L = [moveforward])
			)
		)
		
    ).


retracePath(X,Y,D,L) :-
	N is Y + 1, %top
	E is X + 1, %right
	S is Y - 1, %bottom
	W is X - 1, %left
	(retractall(path(X,Y)); true),
    (
		( %check top
			path(X,N),
			(		 ( D == rnorth, L = [moveforward]);
					( D == rsouth, L = [turnleft,turnleft,moveforward]);
					( D == reast, L = [turnleft,moveforward]);
					( D == rwest, L = [turnright,moveforward] )
			)
		);

		( %check right
			path(E,Y),
			(               ( D == rnorth, L = [turnright,moveforward]);
						( D == rsouth, L = [turnleft,moveforward]);
						( D == reast, L = [moveforward]);
						( D == rwest, L = [turnright,turnright,moveforward] )
			)
		);

		( %check bottom
			path(X,S),
			(         ( D == rnorth, L = [turnright,turnright,moveforward]);
					( D == rsouth, L = [moveforward]);
					( D == reast, L = [turnright,moveforward] );
						( D == rwest, L = [turnleft,moveforward] )
			)
		);

		( %check left
			path(W,Y),
			(
						( D == rnorth, L = [turnleft,moveforward]);
						( D == rsouth, L = [turnright,moveforward]);
						( D == reast, L = [turnright,turnright,moveforward]);
						( D == rwest, L = [moveforward] )
			)
		)
    ).


recursiveBackHome(X,Y,D,L) :-
	N is Y + 1, %top
	E is X + 1, %right
	S is Y - 1, %bottom
	W is X - 1, %left
       (
	( %check top
	  goHome(X,N),
	   (		 ( D == rnorth, L = [moveforward], retractall(goHome(X,N)) );
			 ( D == rsouth, L = [turnleft,turnleft,moveforward], retractall(goHome(X,N)));
			 ( D == reast, L = [turnleft,moveforward] , retractall(goHome(X,N)) );
			 ( D == rwest, L = [turnright,moveforward], retractall(goHome(X,N))  )
	   )
	);

	( %check right
	  goHome(E,Y),
	   (                ( D == rnorth, L = [turnright,moveforward], retractall(goHome(E,Y)) );
	               ( D == rsouth, L = [turnleft,moveforward], retractall(goHome(E,Y)));
	               ( D == reast, L = [moveforward] , retractall(goHome(E,Y)) );
	               ( D == rwest, L = [turnright,turnright,moveforward], retractall(goHome(E,Y))  )
	   )
	);

	( %check bottom
	  goHome(X,S),
	   (         ( D == rnorth, L = [turnright,turnright,moveforward], retractall(goHome(X,S)) );
	           ( D == rsouth, L = [moveforward], retractall(goHome(X,S)));
	           ( D == reast, L = [turnright,moveforward] , retractall(goHome(X,S)) );
	              ( D == rwest, L = [turnleft,moveforward], retractall(goHome(X,S))  )
	    )
	);

	( %check left
	  goHome(W,Y),
	   (
	             ( D == rnorth, L = [turnleft,moveforward], retractall(goHome(W,Y)) );
	             ( D == rsouth, L = [turnright,moveforward], retractall(goHome(W,Y)));
	            ( D == reast, L = [turnright,turnright,moveforward] , retractall(goHome(W,Y)) );
	              ( D == rwest, L = [moveforward], retractall(goHome(W,Y))  )
	  )
	)
       ).

%no choice enter portal
stepsForNoSafeChoice(X,Y,L) :-
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(
		%% Dont walk into wumpus (but no choice enter portal)

		(
			wumpus(X,N),
			(
				(L = [turnleft,turnleft,moveforward])	

			)
		);
		(
			wumpus(X,S),
			(
			       (L = [turnleft,turnleft,moveforward])

			)
		);
		(
			wumpus(E,Y),
			(

			      (L = [turnleft,turnleft,moveforward])

			)
		);
		(
			wumpus(W,Y),
			(

				(L = [turnleft,turnleft,moveforward])

			 )
		)

	).

%walk backwards
stepsWhenSurrounded(X,Y,L) :-
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(
		%% Dont walk into portal/wumpus

				(
			(wumpus(X,N);confundus(X,N)),
			(
				(L = [turnleft,turnleft,moveforward]),
				retractall(goHome(X,Y)),assertz(surrounded(X,Y)),retractall(safeToBacktrack(X,Y))
			)
		);
		(
			(wumpus(X,S);confundus(X,S)),
			(
			       (L = [turnleft,turnleft,moveforward]),
					retractall(goHome(X,Y)),assertz(surrounded(X,Y)),retractall(safeToBacktrack(X,Y))
			)
		);
		(
			(wumpus(E,Y);confundus(E,Y)),
			(

			      (L = [turnleft,turnleft,moveforward]),
					retractall(goHome(X,Y)),assertz(surrounded(X,Y)),retractall(safeToBacktrack(X,Y))
			)
		);
		(
			(wumpus(W,Y);confundus(W,Y)),
			(

				(L = [turnleft,turnleft,moveforward]),
				retractall(goHome(X,Y)),assertz(surrounded(X,Y)),retractall(safeToBacktrack(X,Y))

			 )
		)
	).

stepsForSafeCell(X,Y,D,L):-
	N is Y + 1, %top
	S is Y - 1, %bottom
	E is X + 1, %right
	W is X - 1, %left
	(
			 %%explore new places if no wumpus and no portal
		(
			(\+wumpus(X,N);\+confundus(X,N)),\+wall(X,N),\+visited(X,N),
			(
				(D == rnorth, L = [moveforward]);
				(D == reast, L = [turnleft, moveforward]);
				(D == rsouth, L = [turnright, turnright, moveforward]);
				(D == rwest, L = [turnright, moveforward])
			)
		);
		(
			(\+wumpus(X,S);\+confundus(X,S)),\+wall(X,S),\+visited(X,S),
			(
				(D == rnorth, L = [turnleft,turnleft,moveforward]);
				(D == reast, L = [turnright, moveforward]);
				(D == rsouth, L = [moveforward]);
				(D == rwest, L = [turnleft, moveforward])
			)
		);
		(
			(\+wumpus(E,Y);\+confundus(E,Y)),\+wall(E,Y),\+visited(E,Y),
			(
				(D == rnorth, L = [turnright,moveforward]);
				(D == reast, L = [moveforward]);
				(D == rsouth, L = [turnleft, moveforward]);
				(D == rwest, L = [turnleft,turnleft, moveforward])
			)
		);
		(
			(\+wumpus(W,Y);\+confundus(W,Y)),\+wall(W,Y),\+visited(W,Y),
			(
				(D == rnorth, L = [turnleft,moveforward]);
				(D == reast, L = [turnright,turnright, moveforward]);
				(D == rsouth, L = [turnright, moveforward]);
				(D == rwest, L = [moveforward])
			)
		);

		%% backtrack to safe places when no more other moves to try

			 (
			(safeToBacktrack(X,N),\+surrounded(X,N)),
			(
				(D == rnorth, L = [moveforward]);
				(D == reast, L = [turnleft, moveforward]);
				%(D == rsouth, L = [turnright,turnright, moveforward]);
				(D == rwest, L = [turnright,moveforward])

			)
		);
		(
			(safeToBacktrack(X,S),\+surrounded(X,S)),
			(
				%(D == rnorth, L = [turnleft,turnleft,moveforward]);
				(D == reast, L = [turnright, moveforward]);
				(D == rsouth, L = [moveforward]);
				(D == rwest, L = [turnleft,moveforward])


			)
		);
		(
			(safeToBacktrack(E,Y),\+surrounded(E,Y)),
			(

			      (D == rnorth, L = [turnright,moveforward]);
				(D == reast, L = [moveforward]);
				(D == rsouth, L = [turnleft, moveforward])
				%(D == rwest, L = [turnleft,turnleft,moveforward])
			)
		);
		(
			(safeToBacktrack(W,Y),\+surrounded(W,Y)),
			(

			    (D == rnorth, L = [turnleft,moveforward]);
				%(D == reast, L = [turnright,turnright, moveforward]);
				(D == rsouth, L = [turnright, moveforward]);
				(D == rwest, L = [moveforward])
			 )
		)
	).


killWumpus(X,Y,D,L):-
    locationFound(wumpus),
    wumpus(A,B),
    wumpusX is A,
    wumpusY is B,
    (
              (
               (Y == wumpusY, X < wumpusX ), %same row
               (   D == rnorth, L = [turnright,shoot]);
               (   D == rsouth, L = [turnleft,shoot]);
               (   D == east, L = [shoot]);
               (   D == west, L = [turnright,turnright,shoot])
              );


               (
               (Y == wumpusY, X > wumpusX ), %same row
               (   D == rnorth, L = [turnleft,shoot]);
               (   D == rsouth, L = [turnright,shoot]);
               (   D == east, L = [turnright,turnright,shoot]);
               (   D == west, L = [shoot])
              );


               (
               (X == wumpusX, Y < wumpusY ), %same column
               (   D == rnorth, L = [shoot]);
               (   D == rsouth, L = [turnleft,turnleft,shoot]);
               (   D == east, L = [turnleft,shoot]);
               (   D == west, L = [turnright,shoot])
              );


               (
               (X == wumpusX, Y > wumpusY ), %same column
               (   D == rnorth, L = [turnright,turnright,shoot]);
               (   D == rsouth, L = [shoot]);
               (   D == east, L = [turnright,shoot]);
               (   D == west, L = [turnleft,shoot])
              )

     ).


explore(L):-
	current(X,Y,D),
	(
		
		( glitter(X,Y), L = [pickup] );
		killWumpus(X,Y,D,L);
		stepsWhenSurrounded(X,Y,L);
		( stepsForSafeCell(X,Y,D,L) );
	    %(  stepsForNoSafeChoice(X,Y,L) );
	    ( recursiveBackHome(X,Y,D,L))
		   
		%decide(X,Y,D,L);
		%retracePath(X,Y,D,L)
	).


isEmptyCell(X,Y) :-
	\+stench(X,Y),
	\+tingle(X,Y),
	\+glitter(X,Y),
	safe(X,Y).

safePath(X,Y,X,Y).
safePath(X,Y,A,B) :-
	adj(X,Y,C,D),
	safePath(C,D,A,B).

adj(X,Y,C,D) :-
	(pos(X,C) , Y == D ); % go left(west)
	(pos(Y,D) , X == C ); % go down(south)
	(neg(X,C) , Y == D ); % go right(east)
	(neg(Y,D) , X == C ). % go up (north)

pos(X,Y) :-
	N is X - Y,
	N == 1.

neg(X,Y) :-
	N is Y - X,
	N == 1.

same(X,Y,A,B) :-
	X == A , Y == B.

/*
findNextSafe([]).
findNextSafe(X, [_|T]) :-
	findNextSafe(X,T).

hasSafePath(X,Y,X,Y):-
	same(X,Y,X,Y).
hasSafePath(X,Y,A,B) :-
	safeEdge(X,Y,C,D),
	hasSafePath(C,D,A,B).

same(X,Y,A,B) :-
	X == A ; Y == B.



% x,y is current, c,d is target
adj(X,Y,C,D) :-
	(pos(X,C) , Y == D , experimental(_,_,F),turnUntil(F,rwest),fakeMove,assertz(explore(moveforward))); % go left(west)
	(pos(Y,D) , X == C , experimental(_,_,F),turnUntil(F,rsouth),fakeMove,assertz(explore(moveforward))); % go down(south)
	(neg(X,C) , Y == D , experimental(_,_,F),turnUntil(F,reast),fakeMove,assertz(explore(moveforward))); % go right(east)
	(neg(Y,D) , X == C , experimental(_,_,F),turnUntil(F,rnorth),fakeMove,assertz(explore(moveforward))); % go up (north)


turnUntil(D,D).
turnUntil(D,T):-
	D \== T,
	fakeTurn,
	experimental(_,_,N),
	turnUntil(N,T).


fakeTurn :-
	experimental(X,Y,D),
	(
		(D == rnorth , retractAll(experimental(_,_,_)), assertz(experimental(X,Y,reast)));
		(D == reast , retractAll(experimental(_,_,_)), assertz(experimental(X,Y,rsouth)));
		(D == rsouth , retractAll(experimental(_,_,_)), assertz(experimental(X,Y,rwest)));
		(D == rwest , retractAll(experimental(_,_,_)), assertz(experimental(X,Y,rnorth)));
	).

fakeMove :-
	experimental(X,Y,D),
	(
		(D == rnorth , retractAll(experimental(_,_,_)), NewY is Y+1, assertz(experimental(X,NewY,D)));
		(D == reast , retractAll(experimental(_,_,_)), NewX is X+1, assertz(experimental(NewX,Y,D)));
		(D == rsouth , retractAll(experimental(_,_,_)), NewY is Y-1, assertz(experimental(X,NewY,D)));
		(D == rwest , retractAll(experimental(_,_,_)), NewX is X-1, assertz(experimental(NewX,Y,D)));
	).
		*/

/*
pos(X,Y) :-
	N is X - Y,
	N == 1.

neg(X,Y) :-
	N is Y - X,
	N == 1.
*/
/*
handleSafeCell :-
	current(X,Y,D),
	safe(X,Y,D),
	assertz(explore(moveforward)).
*/







