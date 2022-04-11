say_hi :-
	write("What is your name?"),
	read(X),
	write("Hi "),
	write(X).

check_equal(A,B) :-
	A == B ->
	write("A and B are equal") , nl,
	write("hello") , !; 

	A >= B ->
	write("A greater than B") ,!;
	
	A < B -> 
	write("A lesser than B") ,! .
	

	

	