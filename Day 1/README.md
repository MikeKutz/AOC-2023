# 2023 Day 1: Trebruchet?!

## Part 1

The original answer used `translate` and `replace` to remove all non-digits from the string. 

Then, using `substr`, I extracted the First Digit and the Last.

## Part 2

Now, we need to identify the string `one` as the digit `1`

I cheated and fond the string `1` as the digit `1` also. (ie its part of my translation table)

This answer uses a few Oracle SQL techniques. Some might be available in other RDBMSs

- `connect by level <= n` is used as an iterator
- `to_date( <date>, 'year')` spells out the number
- `instr( string, substr, -1 )` finds the *last* occurance
- `min( n ) keep (dense_rank first order by ... )`
- `apex_string.split()` converts the input CLOB into rows.

## NOTES

- SQL Developer 23.1 had a problem with binding ( `:input` ) the large input string.
- `from dual` is no longer needed (in most cases) on 23c
- problems with `boolean` data types still exist.
- I still have a few things to do to clean up this one
