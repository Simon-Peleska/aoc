import math

file = open("input", "r")

level = 2

count = 0
num = 50

for line in file:
    was_zero = num == 0

    if line.startswith("L"):
        num -= int(line[1:])
    else:
        num += int(line[1:])

    if level == 1:
        num %= 100
        if not was_zero and num == 0:
            count += 1

    if level == 2:
        if not was_zero and num <= 0:
            count += 1

        count += math.floor(abs(num / 100))
        num %= 100

print(count)
