file = open("input", "r")
# file = open("input2", "r")
level: int = 2

def main():
    points: list[list[int]] = [
        [int(coord) for coord in line.split(",")] for line in file.readlines()
    ]

    max_size = 0

    for i in range(len(points)):
        for j in range(len(points)):
            x_min = min([points[i][0], points[j][0]])
            x_max = max([points[i][0], points[j][0]])
            y_min = min([points[i][1], points[j][1]])
            y_max = max([points[i][1], points[j][1]])

            size = (1 + x_max - x_min) * (1 + y_max - y_min)

            if size <= max_size:
                continue

            if level == 2:
                empty = True
            
                for point in points:
                    if x_min < point[0] < x_max and y_min < point[1] < y_max:
                        empty = False
                        break

                if not empty:
                    continue

                center_x = (x_min + x_max) // 2
                center_y = (y_min + y_max) // 2

                crossings_above = 0
                crossings_below = 0
                crossing_through = False
                crossings_left = 0
                crossings_right = 0

                for k in range(len(points)):
                    k_x_min = min([points[k][0], points[k - 1][0]])
                    k_x_max = max([points[k][0], points[k - 1][0]])
                    k_y_min = min([points[k][1], points[k - 1][1]])
                    k_y_max = max([points[k][1], points[k - 1][1]])

                    if points[k][1] == points[k - 1][1]:
                        if k_x_min <= center_x < k_x_max:
                            if points[k][1] <= y_min:
                                crossings_above += 1
                            elif points[k][1] >= y_max:
                                crossings_below += 1
                            else:
                                crossing_through = True
                                break

                    elif points[k][0] == points[k - 1][0]:
                        if k_y_min <= center_y < k_y_max:
                            if points[k][0] <= x_min:
                                crossings_left += 1
                            elif points[k][0] >= x_max:
                                crossings_right += 1
                            else:
                                crossing_through = True
                                break

                if crossing_through:
                    continue
            
                if crossings_above % 2 == 0:
                    continue
                            
                if crossings_below % 2 == 0:
                    continue
                            
                if crossings_left % 2 == 0:
                    continue
                            
                if crossings_right % 2 == 0:
                    continue

            max_size = size

    print(max_size)

if __name__ == "__main__":
    main()
