import math

file = open("input", "r")
level = 2


def main():
    count = 0

    lines = file.readlines()

    if level == 1:
        numbers1 = list(map(int, lines[0].split()))
        numbers2 = list(map(int, lines[1].split()))
        numbers3 = list(map(int, lines[2].split()))
        numbers4 = list(map(int, lines[3].split()))
        operations = lines[4].split()

        print(operations)

        for i in range(len(numbers1)):
            if operations[i] == "+":
                count += numbers1[i] + numbers2[i] + numbers3[i] + numbers4[i]
            else:
                count += numbers1[i] * numbers2[i] * numbers3[i] * numbers4[i]
    else:
        lines = ["".join(col) for col in zip(*lines)]

        operation = ""
        numbers = []

        for line in lines:
            if line.strip() == "":
                if operation == "+":
                    count += sum(numbers)
                elif operation == "*":
                    count += math.prod(numbers)

                operations = ""
                numbers = []
                continue

            if line[4] != " ":
                operation = line[4]

            numberStr = line[:4].replace(" ", "")
            number = int(numberStr)
            numbers.append(number)

    print(count)


if __name__ == "__main__":
    main()
