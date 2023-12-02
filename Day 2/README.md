#  Day 2: Cube Conundrum

Game 1: 3 red, 4 green, 5 blue; 12 red, 10 green 6 blue; ...

Use `cross apply apex_string.split()` to parse the string from the previous table.

- split per line
  - game ID
  - game number
- split per set
  - rownum for grouping
- split per color
  - count
  - color name
- `pivot` for easier answer

## Part 1

The hardest problem was I keep forgetting all the common data "gotcha's"

- `null <= 10 and ...` is NULL
- only wanted valid "games", not sets

SQL doesn't have easy sub-set analysis capabilities. Something to investigate.

## Part 2

This was easy. I just had to find the maximum value of each game then "math".

It could be done better.

## Redux

I could probably pivot on `max()` of each game then perform the calculations



