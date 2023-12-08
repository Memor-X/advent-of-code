# --- [Day 1: Trebuchet?!](https://adventofcode.com/2023/day/1) ---
## --- Part Two ---
Your calculation isn't quite right. It looks like some of the digits are actually **spelled out with letters**: one, two, three, four, five, six, seven, eight, and nine **also** count as valid "digits".

Equipped with this new information, you now need to find the real first and last digit on each line. For example:

```
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces **281**.

**What is the sum of all of the calibration values?**

## --- Approach ---
using Part 1's Solution. inside Input Loop processing
1. find first and last instance of worded numbers
2. record which integer they represent
3. insert integer into the position of worded numbers
4. proceed with number extraction