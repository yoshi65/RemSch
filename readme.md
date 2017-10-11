# RemSch
Show the remaining schedule of today from [icalBuddy](http://hasseg.org/icalBuddy/) 

## usage
```
usage: ./RemSch.sh [-f] [-nc] [-num NUM]

Show the remaining schedule of today from icalBuddy(http://hasseg.org/icalBuddy/)

optional arguments:
  -f		Format output
  -nc		No calendar names
  -num NUM	Print events occurring between today and NUM days into the future
```

## default original data in RemSch
```
% icalBuddy -sd eventsToday+1
```

## example
```
% ./RemSch.sh
or
% ./RemSch.sh -num 2
```
