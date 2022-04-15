
from cgitb import reset
import random
from webbrowser import Grail
from pyswip import Prolog
prolog = Prolog()
prolog.consult("test.pl")
# print(list(prolog.query("check_equal(2,2)")))

# coordinate translation
# examples
# 1 c,1 r = 29
# 0 c,1 r = 28
# 0 c,0 r = 35
# 6 c,0 r = 41
# 0 c,5 r = 0

# (grid_x * grid_y) - (grix_x + (r x grid_x)) + c = index

# relative coordinate translation
# examples
# 3x3, 4
# 5x5, 12
# 7x7, 24
# 9x9, 40
# center = (x**2 - 1 ) / 2


GRID_X = 7
GRID_Y = 6
CONTENT_SIZE = 3

relativeSize = 3

directions = ["north","east","south","west"]
# orientation is the index of directions
orientation = 0
currentCell = 35
prevNPC = "?"
gameOver = False

# Confounded, Stench, Tingle, Glitter, Bump, Scream.
currentSenses = ["on","off","off","off","off","off"]

cells = [["?" for i in range(CONTENT_SIZE * CONTENT_SIZE)] for j in range(GRID_X * GRID_Y)]

for elem in cells[0]:
    elem += "1"

def test():
    for i in range(len(cells)):
        for j in range(len(cells[0])):
            cells[i][j] = i
    
def test2():
    for i in range(len(cells)):
        for j in range(len(cells[0])):
            cells[i][j] = "{}({})".format(i,j)
    
def displayGrid():

    grid = ""

    for l in range(GRID_Y):
        for j in range(CONTENT_SIZE):
            for i in range(GRID_X):
                grid += ((" {} ").format(cells[i][0]) + (" {} ").format(cells[i][1]) + (" {} ").format(cells[i][2]) + "|")
            grid += "\n"

        for k in range(GRID_X):
            for times in range(CONTENT_SIZE):
                grid += "---"
            grid += "+"
        grid += "\n"

    print(grid)

def displayGridDynamic():

    grid = ""

    for y in range(GRID_Y):

        for size in range(CONTENT_SIZE):
            for x in range(GRID_X):
                grid += (("{} ").format(cells[y*GRID_Y + x + y][size * CONTENT_SIZE]) + ("{} ").format(cells[y*GRID_Y + x + y][size * CONTENT_SIZE + 1]) + ("{}").format(cells[y*GRID_Y + x + y][size * CONTENT_SIZE + 2]) + "   ")
            grid += "\n"

        grid += "\n" 
        #for k in range(GRID_X):
        #    for times in range(CONTENT_SIZE):
        #        grid += "---"
        #    grid += "+"
        #grid += "\n"

    print(grid)

def displayRelativeGrid():

    global relativeSize

    visited = list(prolog.query("visited(X,Y)"))
    print("agent visited:")
    for coord in visited:
        x = coord.get('X')
        y = coord.get('Y')
        print("{},{}".format(x,y))
        if abs(x) > (relativeSize-1)/2 or abs(y) > (relativeSize-1)/2:
            relativeSize+=2
            return displayRelativeGrid()
        
    grid = [["?" for i in range(CONTENT_SIZE * CONTENT_SIZE)] for j in range(relativeSize * relativeSize)]
    origin = (relativeSize*relativeSize - 1) / 2
    print()

    for coord in visited:
        x = coord.get('X')
        y = coord.get('Y')
        target = int(origin) + x - (y * relativeSize)

        # querying kb for each symbol
        grid[target][0] = "%" if bool(list(prolog.query("confundus({},{})".format(x,y)))) else "."
        grid[target][1] = '=' if bool(list(prolog.query("stench({},{})".format(x,y)))) else "."
        grid[target][2] = "T" if bool(list(prolog.query("tingle({},{})".format(x,y)))) else "."
        grid[target][3] = '-' if len(list(prolog.query("current({},{},D)".format(x,y)))) > 0 or bool(list(prolog.query("wumpus({},{})".format(x,y)))) else "."

        temp = " "
        if bool(list(prolog.query("wumpus({},{})".format(x,y)))) and bool(list(prolog.query("confundus({},{})".format(x,y)))):
            temp = "U"
        elif bool(list(prolog.query("wumpus({},{})".format(x,y)))):
            temp = "W"
        elif bool(list(prolog.query("confundus({},{})".format(x,y)))):
            temp = "O"
        elif len(list(prolog.query("current({},{},D)".format(x,y)))) > 0:
            direction = list(prolog.query("current({},{},D)".format(x,y)))[0]
            if direction == "(r)north":
                direction = "^"
            elif direction == "(r)south":
                direction = "v"
            elif direction == "(r)east":
                direction = ">"
            elif direction == "(r)west":
                direction = "<"

            temp = direction
        elif bool(list(prolog.query("safe({},{})".format(x,y)))) and not bool(list(prolog.query("visited({},{})".format(x,y)))):
            temp = "s"
        elif bool(list(prolog.query("safe({},{})".format(x,y)))) and bool(list(prolog.query("visited({},{})".format(x,y)))):
            temp = "S"
        else:
            temp = "?"

        grid[target][4] = temp
        grid[target][5] = '-' if len(list(prolog.query("current({},{},D)".format(x,y)))) > 0 or bool(list(prolog.query("wumpus({},{})".format(x,y)))) else "."
        grid[target][6] = '*' if bool(list(prolog.query("glitter({},{})".format(x,y)))) else "."
        grid[target][7] = 'B' if currentSenses[4] == "on" else "."
        grid[target][8] = '@' if currentSenses[5] == "on" else "."

    rgrid = ""

    for i in range(relativeSize):
        for j in range(relativeSize):
            rgrid += ("{} {} {}   ".format(grid[i * relativeSize + j][0],grid[i * relativeSize + j][1],grid[i * relativeSize + j][2]))
        rgrid += "\n"
        for j in range(relativeSize):
            rgrid += ("{} {} {}   ".format(grid[i * relativeSize + j][3],grid[i * relativeSize + j][4],grid[i * relativeSize + j][5]))
        rgrid += "\n"
        for j in range(relativeSize):
            rgrid += ("{} {} {}   ".format(grid[i * relativeSize + j][6],grid[i * relativeSize + j][7],grid[i * relativeSize + j][8]))
        rgrid += "\n\n"
        
    print(rgrid)

def getPointer(o):
    if o == "north":
        return "^"
    if o == "south":
        return "v"
    if o == "east":
        return ">"
    if o == "west":
        return "<"

def move():

    global prevNPC
    global relativeSize
    global currentCell
    prevCell = currentCell
    
    facing = directions[orientation]

    if facing == "north":
        if currentCell - GRID_X > -1:
            currentCell -= GRID_X
        else:
            print("what are you doing?")

    if facing == "south":
        if currentCell + GRID_X < (GRID_X * GRID_Y):
            currentCell += GRID_X
        else:
            print("what are you doing?")

    if facing == "east":
        if (currentCell) % GRID_X is not GRID_X-1:
            currentCell += 1
        else:
            print("what are you doing?")

    if facing == "west":
        if (currentCell) % GRID_X is not 0:
            currentCell -= 1
        else:
            print("what are you doing?")


    if cells[currentCell][0] == "#":
        currentCell = prevCell
        sense()
        currentSenses[4] = "on"
    elif cells[currentCell][4] == "W":
        print("Agent killed by wumpus.")
        print("Resetting world...")
        setupWorld()
    else:
        cells[prevCell][4] = prevNPC
        prevNPC = ""+cells[currentCell][4]
        cells[currentCell][4] = getPointer(directions[orientation])
        sense()
        

def turn(x):
    global orientation
    if orientation + x >= len(directions):
        orientation = 0
    elif orientation + x < 0:
        orientation = len(directions)-1
    else:
        orientation += x

    cells[currentCell][4] = getPointer(directions[orientation])
    # turn bump(if it was on) off after turning
    currentSenses[4] = "off"

def sense():
    # Confounded, Stench, Tingle, Glitter, Bump, Scream.
    current = cells[currentCell]
    currentSenses[0] = "off"
    currentSenses[1] = "on" if current[1] == "=" else "off"
    currentSenses[2] = "on" if current[2] == "T" else "off"
    currentSenses[3] = "on" if current[6] == "*" else "off"
    currentSenses[4] = "off"
    currentSenses[5] = "off"

def printSenses():
    a = "Confounded" if currentSenses[0] == "on" else "C"
    b = "Stench" if currentSenses[1] == "on" else "S"
    c = "Tingle" if currentSenses[2] == "on" else "T"
    d = "Glitter" if currentSenses[3] == "on" else "G"
    e = "Bump" if currentSenses[4] == "on" else "B"
    f = "Scream" if currentSenses[5] == "on" else "S"

    print("[{}-{}-{}-{}-{}-{}]".format(a,b,c,d,e,f))

def grabCoin():
    global cells

    if cells[currentCell][6] == "*":
        cells[currentCell][6] = "."


def shoot():
    global cells
    global currentSenses

    fly = 1

    if orientation == 0:
        fly = -GRID_X
    elif orientation == 1:
        fly = 1
    elif orientation == 2:
        fly = GRID_X
    elif orientation == 3:
        fly = -1

    nextCell = currentCell + fly

    while nextCell >= 0 and nextCell < (GRID_X * GRID_Y):
        if cells[nextCell][4] == "W":
            currentSenses[5] = "on"
            cells[nextCell][4] = "S"

            x = nextCell

            if(x+1 >= 0 and x+1 < GRID_X*GRID_Y and cells[x+1][1] != '#'):
                cells[x+1][1] = '.'

            if(x-1 >= 0 and x-1 < GRID_X*GRID_Y and cells[x-1][1] != '#'):
                cells[x-1][1] = '.'

            if(x+GRID_X >= 0 and x+GRID_X < GRID_X*GRID_Y and cells[x+GRID_X][1] != '#'):
                cells[x+GRID_X][1] = '.'

            if(x-GRID_X >= 0 and x-GRID_X < GRID_X*GRID_Y and cells[x-GRID_X][1] != '#'):    
                cells[x-GRID_X][1] = '.'


            break
        
        nextCell += fly


def handleInput(input):
    global orientation
    global gameOver
    
    if input == "turn left":
        turn(-1)

    if input == "turn right":
        turn(1)
        
    if input == "move":
        move()

    if input == "test":
        #print(bool(list(prolog.query("visited(0,1)"))))
        print(list(prolog.query("visited(X,Y)")))

    if input == "end":
        gameOver = True

    if input == "shoot":
        shoot()

    
def initializeCellData():

    global cells

    for i in range(len(cells)):
        cells[i][0] = "."
        cells[i][1] = "."
        cells[i][2] = "."
        cells[i][3] = " "
        cells[i][4] = "?"
        cells[i][5] = " "
        cells[i][6] = "."
        cells[i][7] = "."
        cells[i][8] = "."


def spawnCoin():
    x = random.randint(0,(GRID_X*GRID_Y )-1)
    if cells[x][6] != '.' or cells[x][4] == 'W' or cells[x][4] == 'O':
        return spawnCoin()
    cells[x][6] = '*'

def spawnConfundus():
    x = random.randint(0,(GRID_X*GRID_Y )-1)
    if cells[x][4] != '?':
        return spawnConfundus()

    cells[x][4] = 'O'

    if(x+1 >= 0 and x+1 < GRID_X*GRID_Y and cells[x+1][1] != "#"):
        cells[x+1][2] = 'T'

    if(x-1 >= 0 and x-1 < GRID_X*GRID_Y and cells[x-1][1] != "#"):
        cells[x-1][2] = 'T'

    if(x+GRID_X >= 0 and x+GRID_X < GRID_X*GRID_Y and cells[x+GRID_X][1] != "#"):
        cells[x+GRID_X][2] = 'T'

    if(x-GRID_X >= 0 and x-GRID_X < GRID_X*GRID_Y) and cells[x-GRID_X][1] != "#":    
        cells[x-GRID_X][2] = 'T'

def spawnWumpus():
    x = random.randint(0,(GRID_X*GRID_Y )-1)
    if cells[x][4] != '?':
        return spawnWumpus()

    cells[x][4] = 'W'

    if(x+1 >= 0 and x+1 < GRID_X*GRID_Y and cells[x+1][1] != '#'):
        cells[x+1][1] = '='

    if(x-1 >= 0 and x-1 < GRID_X*GRID_Y and cells[x-1][1] != '#'):
        cells[x-1][1] = '='

    if(x+GRID_X >= 0 and x+GRID_X < GRID_X*GRID_Y and cells[x+GRID_X][1] != '#'):
        cells[x+GRID_X][1] = '='

    if(x-GRID_X >= 0 and x-GRID_X < GRID_X*GRID_Y and cells[x-GRID_X][1] != '#'):    
        cells[x-GRID_X][1] = '='

def spawnAgent():
    global currentCell

    x = random.randint(0,(GRID_X*GRID_Y )-1)
    if cells[x][4] != '?':
        spawnAgent()
    else:
        cells[x][4] = '^'
        currentCell = x

def setWalls():
    for n in range(0,GRID_X):
        for i in range(len(cells[n])):
            cells[n][i] = '#'

    for s in range((GRID_X * GRID_Y) - GRID_X,GRID_X * GRID_Y):
        for i in range(len(cells[s])):
            cells[s][i] = '#'

    for e in range((GRID_X - 1),GRID_X*GRID_Y,GRID_X):
        for i in range(len(cells[e])):
            cells[e][i] = '#'

    for w in range(0,((GRID_Y * GRID_X )- GRID_X),GRID_X):
        for i in range(len(cells[w])):
            cells[w][i] = '#'


def resetSenses():
    global currentSenses
    for i in range(len(currentSenses)):
        currentSenses[i] = "off"

def resetAgent():
    global orientation
    orientation = 0

def setupWorld():
    initializeCellData()
    setWalls()
    for i in range(3):
        spawnConfundus()
    spawnWumpus()
    spawnCoin()
    spawnAgent()
    resetAgent()
    resetSenses()
    sense()

if __name__ == '__main__':
    #test2()
    setupWorld()

    while gameOver is False:
        displayGridDynamic()
        #displayRelativeGrid()
        print(currentSenses)
        printSenses()

        temp = input("\nenter input: ")
        handleInput(temp)
        


