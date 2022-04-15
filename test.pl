
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

visited(0,0).
current(0,0,(r)north)

wumpus(X,Y) :-
    stench(X+1,Y);
    stench(X-1,Y);
    stench(X,Y+1);
    stench(X,Y-1)

confundus(X,Y) :-
    tingle(X+1,Y);
    tingle(X-1,Y);
    tingle(X,Y+1);
    tingle(X,Y-1)


safe(X,Y) :-
	\+wumpus(X,Y),
	\+confundus(X,Y),
	assertz(safe(X,Y)).


%shoot,moveforward,turnleft,turnright,pickup
%Confounded, Stench, Tingle, Glitter, Bump, Scream.


    



