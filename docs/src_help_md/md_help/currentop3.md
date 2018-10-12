---
title: 'current_op/3'
predicates:
 - 'current_op/3' : retrieve current operator definitions
---
`current_op/3` — retrieve current operator definitions


## FORMS

current_op(Priority, Specifier, Operator)


## DESCRIPTION

current_op/3 is used to retrieve operator definitions. Each parameter to current_op may be used as either an input or output argument. Logically, current_op(Priority, Specifier, Operator) is true if and only if Operator is an operator with properties defined by Specifier and Priority.


## EXAMPLES

```
?- current_op(P,S,-).
P=500
S=yfx;
P=200
S=fy;
no.
```


## NOTES

close/1 may change the current input or current output streams.


## SEE ALSO

- `op/3`  
`read_term/[2`  
`3]`
- `User Guide (Prolog I/O).