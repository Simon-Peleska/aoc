file = open("input", "r")
# file = open("input2", "r")
level = 2
# y_len = len(lines)


def main():
    count = 0
    first_line =  list(file.readline());
    start_index = first_line.index("S")
    x_len = len(first_line)
    locs = [0] * x_len
    locs[start_index] = 1

    for line in file:
        new_locs: list[int] = [0] * x_len

        for x in range(x_len):
            if line[x] != "^":
                new_locs[x] += locs[x]

                if x - 1 >= 0 and line[x - 1] == "^":
                    new_locs[x] += locs[x - 1]

                if x + 1 < x_len and line[x + 1] == "^":
                    if level == 1:
                        if locs[x + 1] > 0:
                            new_locs[x] += 1
                    else:
                        new_locs[x] += locs[x + 1]

        locs = new_locs

    count = sum(locs)

    if level == 1:# remove initial
        count -= 1 

    print(count)


if __name__ == "__main__":
    main()
