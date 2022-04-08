

GRID_X = 7
GRID_Y = 6
CONTENT_SIZE = 3

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
            # symbols 1-3 if any
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





# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    #test2()
    cells[41][4] = 'W'
    displayGridDynamic()

