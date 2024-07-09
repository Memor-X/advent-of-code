# --- [Day 6: Wait For It](https://adventofcode.com/2023/day/6) ---
## --- Part Two ---
As the race is about to start, you realize the piece of paper with race times and record distances you got earlier actually just has very bad [kerning](https://en.wikipedia.org/wiki/Kerning). There's really **only one race** - ignore the spaces between the numbers on each line.

So, the example from before:

```
Time:      7  15   30
Distance:  9  40  200
```

...now instead means this:

Time:      71530
Distance:  940200
Now, you have to figure out how many ways there are to win this single race. In this example, the race lasts for **71530 milliseconds** and the record distance you need to beat is **940200 millimeters**. You could hold the button anywhere from 14 to 71516 milliseconds and beat the record, a total of **71503** ways!

**How many ways can you beat the record in this one much longer race?**

## --- Unit Testing ---

Code Coverage Req: 90%

| File | No. of Tests | Code Coverage |
| :--- | :---: | ---: |
| LocalLib.ps1 | 9 | <span style="color:green">100%</span> |
| **Total** | 9 | <span style="color:green">100%</span> |

## --- Approach ---
1. Load data into array
2. strip out row titles and all spaces
3. calculate half of race (distance from charge time is a bell curve, dimishing returns after midway
4. determin when winner start
5. calculate how many winners from start time to mid point, then double for other half
    - if no winner start, be 0