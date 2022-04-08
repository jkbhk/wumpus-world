

GRID_X = 7
GRID_Y = 6
CONTENT_SIZE = 3

directions = ["north","east","south","west"]
orientation = 0
pos_x = 0
pos_y = 0
currentCell = 35

gameOver = False

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
                grid += ((" {} ").format(cells[y*GRID_Y + x + y][size * CONTENT_SIZE]) + (" {} ").format(cells[y*GRID_Y + x + y][size * CONTENT_SIZE + 1]) + (" {} ").format(cells[y*GRID_Y + x + y][size * CONTENT_SIZE + 2]) + "|")
            grid += "\n"

        for k in range(GRID_X):
            for times in range(CONTENT_SIZE):
                grid += "---"
            grid += "+"
        grid += "\n"

    print(grid)


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

    global currentCell
    global gameOver
    prevCell = currentCell
    
    facing = directions[orientation]


    if facing == "north":
        if currentCell - GRID_X > -1:
            currentCell -= GRID_X
        else:
            print("bump")
            gameOver = True

    if facing == "south":
        if currentCell + GRID_X < (GRID_X * GRID_Y):
            currentCell += GRID_X
        else:
            print("bump")
            gameOver = True

    if facing == "east":
        if (currentCell) % GRID_X is not GRID_X-1:
            currentCell += 1
        else:
            print("bump")
            gameOver = True

    if facing == "west":
        if (currentCell) % GRID_X is not 0:
            currentCell -= 1
        else:
            print("bump")
            gameOver = True


    cells[prevCell][4] = "?"
    cells[currentCell][4] = getPointer(directions[orientation])


def turn(x):
    global orientation
    if orientation + x >= len(directions):
        orientation = 0
    elif orientation + x < 0:
        orientation = len(directions)-1
    else:
        orientation += x

    cells[currentCell][4] = getPointer(directions[orientation])

def handleInput(input):
    global orientation
    
    if input == "turn left":
        turn(-1)

    if input == "turn right":
        turn(1)
        
    if input == "move":
        move()

    

# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    #test2()
    cells[41][4] = 'W'
    cells[35][4] = '^'

    while gameOver is False:
        displayGridDynamic()
        temp = input("enter input: ")
        handleInput(temp)


