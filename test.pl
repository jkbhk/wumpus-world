
:- dynamic([
       visited/2
]).

visited(5,5).
visited(0,0).

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




