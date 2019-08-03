import random

def guess(r):
    count = 1
    curMax, curMin = r, 0
    g = (curMax + curMin) // 2

    while g != target:
        if g < target:
            print("Guess number", g, 'is too small,', count, 'try')
            curMin = g + 1
        else:
            print("Guess number", g, 'is too large,', count, 'try')
            curMax = g - 1
        g = (curMax + curMin) // 2
        count += 1
    print("Got it correct in", count, "try")



    # int count = 1;
    #     int curMax = range - 1, curMin = 0;
    #     int guess = (curMax + curMin) / 2;
    #     while (guess != number) {
    #         System.out.println("Guess " + count++ + ": " + guess);
    #         if (guess < number) {
    #             curMin = guess;
    #         } else {
    #             curMax = guess;
    #         }
    #         guess = (curMin + curMax) / 2;
    #     }


r = int(input("Type in an integer as range: "))
target = random.randint(0, r)

print('target', target)
guess(r)
