file = open("input", "r")

level = 1
numSize = 2 if level == 1 else 12
sum = 0

for line in file:
    line_list = list(line)
    line_list.pop()
    digits = list(map(int, line_list))

    num = 0
    for i in range(numSize):
        used_digits = digits[: len(digits) - (numSize - 1 - i)]

        maxNum: int = max(used_digits)
        maxIdx = digits.index(maxNum)
        digits = digits[maxIdx + 1 :]

        num += maxNum * (10 ** (numSize - 1 - i))

    sum += num
print(sum)
