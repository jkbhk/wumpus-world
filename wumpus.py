

GRID_X = 7
GRID_Y = 6
CONTENT_SIZE = 3

def displayGrid():

    grid = ""

    for l in range(GRID_Y):
        for j in range(CONTENT_SIZE):
            for i in range(GRID_X):
                grid += ((CONTENT_SIZE * 3 * " ") + "|")
            grid += "\n"

        for k in range(GRID_X):
            for times in range(CONTENT_SIZE):
                grid += "---"
            grid += "+"
        grid += "\n"

    print(grid)





# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    displayGrid()

