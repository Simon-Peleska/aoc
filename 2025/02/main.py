file = open("input", "r")

level = 2

sum = 0

for line in file:
    [start, end] = line.split("-")

    for num in range(int(start), int(end)+1):
        numStr = str(num)
        numStrLen = numStr.__len__()

        if level == 1:
            if numStrLen % 2 == 1:
                continue

            if numStr[0:numStrLen//2] == numStr[numStrLen//2:numStrLen] :
                sum += num

        if level == 2:
            for sliceLen in range(1, (numStrLen // 2) +1):
                if numStrLen / sliceLen != numStrLen // sliceLen:
                    continue

                startSlice = numStr[0:sliceLen]

                isInvalid = True
                for pos in range(1, (numStrLen // sliceLen)):
                    if startSlice != numStr[pos * sliceLen: (pos + 1) * sliceLen]:
                        isInvalid = False
                        break

                if isInvalid:
                    sum += num
                
print(sum)
