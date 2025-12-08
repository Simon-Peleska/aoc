file = open("input", "r")

level = 1
ranges = []


def main():
    count = 0

    for line in file:
        if line == "\n":
            break

        rangeArray = line.split("-")

        start = int(rangeArray[0])
        end = int(rangeArray[1])

        for range in ranges.copy():
            if range[0] <= start and start <= range[1]:
                start = range[1] + 1

            if range[0] <= end and end <= range[1]:
                end = range[0] - 1

            if start <= range[0] and range[1] <= end:
                ranges.remove(range)

        if end - start < 0:
            continue

        range = (start, end)
        ranges.append(range)

    if level == 1:
        for line in file:
            number = int(line.split()[0])

            for range in ranges:
                if range[0] <= number and number <= range[1]:
                    count += 1
                    break
    else:
        for range in ranges:
            count += range[1] - range[0] + 1

    print(count)


if __name__ == "__main__":
    main()
