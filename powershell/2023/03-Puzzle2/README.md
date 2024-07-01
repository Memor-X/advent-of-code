# --- [Day 3: Gear Ratios](https://adventofcode.com/2023/day/3) ---
## --- Part Two ---
Yhe engineer finds the missing part and installs it in the engine! As the engine springs to life, you jump in the closest gondola, finally ready to ascend to the water source.

You don't seem to be going very fast, though. Maybe something is still wrong? Fortunately, the gondola has a phone labeled "help", so you pick it up and the engineer answers.

Before you can explain the situation, she suggests that you look out the window. There stands the engineer, holding a phone in one hand and waving with the other. You're going so slowly that you haven't even left the station. You exit the gondola.

The missing part wasn't the only issue - one of the gears in the engine is wrong. A **gear** is any * symbol that is adjacent to **exactly two part numbers.** Its **gear ratio** is the result of multiplying those two numbers together.

This time, you need to find the gear ratio of every gear and add them all up so that the engineer can figure out which gear needs to be replaced.

Consider the same engine schematic again:

```
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
```

In this schematic, there are **two** gears. The first is in the top left; it has part numbers 467 and 35, so its gear ratio is 16345. The second gear is in the lower right; its gear ratio is 451490. (The * adjacent to 617 is **not** a gear because it is only adjacent to one part number.) Adding up all of the gear ratios produces **467835**.

What is the sum of all of the gear ratios in your engine schematic?

## --- Unit Testing ---

Code Coverage Req: 90%

| File | No. of Tests | Code Coverage |
| :--- | :---: | ---: |
| LocalLib.ps1 | 0 | <span style="color:green">100%</span> |
| **Total** | 0 | <span style="color:green">100%</span> |

## --- Approach ---
1. Load data into array
2. loop though each line
    1. loop through each character
        1. check if the current character is a *
        2. if character is *, check surrounding characters for digits
        3. if digit is found, find the adjacent numbers and store the completed number in array
        4. after checking surroudning characters, if found exactly 2 numbers, multiply and add resutling Gear Ratio to array
3. loop though array of Gear Ratios, summing together

## Check.xlsx
Check.xlsx was used to debug the collected Gear Ratios. in order to load data into it

1. put data in notepad++
2. open find and replace
3. find . and replace with ,.,
4. repeat for all numbers (eg. find 0, replace with ,0,)
5. find ,, and replace with ,
6. save as .csv
7. open .csv in excel
8. copy and paste cells into Check.xlsx

the rules should high light all *'s as green, all numbers surrounding *'s as blue and empty spaces as gold. you can now go though the spreadsheet finding all Gear pairs and deleteing the * to track your progress