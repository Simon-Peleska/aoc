file = open("input", "r")

level = 2
numSize = 2 if level == 1 else 12
grid = []
radius = 1
maxCount = 4

def in_radius(radius, x, y) -> int:
    count = 0
    
    for yPos in range(y - radius, y + radius + 1):
        if yPos < 0 or len(grid) <= yPos:
            continue
        
        for xPos in range(x - radius, x + radius + 1):
            if xPos < 0 or len(grid) <= xPos:
                continue

            count += grid[yPos][xPos]

    return count

def main():

    for line in file:
        rowStrs = list(line.split()[0])
        row = list(map(int, rowStrs))
        grid.append(row)
    
    if(level == 1):  
        count: int = 0

        for y in range(len(grid)):
            for x in range(len(grid[0])):
                if grid[y][x] == 1 and in_radius(radius, x, y) <= maxCount:
                    count += 1

        print(count)
    else:
        removedCount = 0
        
        while True:
            count = 0
    
            for y in range(len(grid)):
                for x in range(len(grid[0])):
                    if grid[y][x] == 1 and in_radius(radius, x, y) <= maxCount:
                        count += 1
                        removedCount += 1
                        grid[y][x] = 0

            if count == 0:
                break

        print(removedCount)
    

if __name__ == "__main__":
    main()

# for y, line in enumerate(grid):
#     print(y)

# print(grid[0][0])

# print(sum)
