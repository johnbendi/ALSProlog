---
title: 'printf/[1,2,3,4]'
group: Input Output
predicates:
- {sig: 'printf', args: {
    1: 'print out a string to the current output',
    2: 'print out a string with arguments',
    3: 'print out a string with a format and arguments',
    4: 'print out string with format, arguments, options'
  }}
- {sig: 'printf_opt/3', desc: 'print out string with format, arguments, options'}
---

## FORMS
```
printf(Format)

printf(Format, ArgList)

printf(Steam_or_Alias, Format, ArgList)

printf_opt(Format, ArgList, WriteOptions)

printf(Stream_or_Alias, Format, ArgList, WriteOptions)
```
## DESCRIPTION

`printf/2` takes a format string and a list of arguments to include in the format string. `printf/1` is the same as `printf/2` except no argument list is given. The following is a list of the special formatting possible within the format string :

`\n` -- prints a newline (same as `nl/0`)

`\t` -- prints a tab character

`\\` -- prints a backslash

`\%` -- prints a percent sign

`%c` -- prints the corresponding Prolog character(atom) in the argument list

`%d` -- prints the corresponding decimal number in the argument list

`%s` -- prints the corresponding Prolog string in the argument list

`%t` -- prints the corresponding Prolog term in the argument list (same as [`write/1`](write.html))

All other characters are printed as they appear in the format string.

Using printf is generally much easier than using the equivalent [`write/1`](write.html), [`put/1`](put.html), and `nl/0` predicates because the whole message you want to print out can be assembled and carried out by one call to `printf`.

## EXAMPLES
```
?- printf('hello world\n').
hello world

yes.

?- printf('Letters: %c%c%c\n', [a,b,c]).
Letters: abc

yes.

?- printf('Contents: %t, Amount: %d\n', [pocket(keys,wallet,watch), 3]).
Contents: pocket(keys,wallet,watch), Amount: 3

yes.
```
## SEE ALSO

- `nl/0` {%- comment %} TODO: missing {% endcomment %}
- [`put/1`](put.html)
- [`write/[1,2]`](write.html)

- [User Guide (Prolog I/O)](../guide/10-Prolog-I-O.html)
- Unix/C Reference Manuals: printf(3S)