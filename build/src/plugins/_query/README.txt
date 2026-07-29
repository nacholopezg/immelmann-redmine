This plugin allows a simple use of OR operator in query.
It seems to work from 2.6 to 3.3 (I am using 3.3 but I developed this based on 2.x)

I. Between different filters

This plugin adds three new filters, acting as markers: All follow (OR), Any follow (AND), Any follow (OR)
Here is how it works

1. All the filters to be ANDed (if any) should come first. They will be joined with AND as usual. Lets call it A part, A can be empty
2. Then comes one of the Marker filters: All follow (OR), Any follow (AND), Any follow (OR), lets call it M
3. Then come other filters for example f1, f2, f3

The result will be 
A. If M is: All follow (OR) is Yes =>  (A) OR (f1 AND f2 AND f3)
            All follow (OR) is not Yes =>  (A) OR NOT (f1 AND f2 AND f3)
B. If M is: Any follow (AND) is Yes => (A) AND (f1 OR f2 OR f3)
            Any follow (AND) is not Yes => (A) AND NOT (f1 OR f2 OR f3)
C. If M is: Any follow (OR) is Yes =>  (A) OR (f1 OR f2 OR f3)
            Any follow (OR) is not Yes =>  (A) OR NOT (f1 OR f2 OR f3)

Notes:
1. It is possible to user more than one Marker in the query. What the term "follow" means is all the filters below till another marker or end.
2. To help debug, I log the result of the statement method (with prefix STATEMENT) into log file at info level . You can exam this log to see if it works correctly


II. Within text field
This plugin adds two operators: match, not match. They are extensions of contains, not contains. 
- They allow 3 logic operators: + (AND), ~ (OR), and ! (NOT). ! can be combined with +, ~ and should come after +,~ (but I do not check). 
- All spaces are removed, so A B will become "AB". If you want to use space, put them within {}, for exampel {A B} will become "A B". In general, everything within {} except with the "}" itself will be treated literally (so {A +-!() B} will become "A +-!() B" 
- You can use () to group items in any way you need. What the match operator does is just search for +,~,! and replace them with AND, OR, NOT, then replace each search term with corresponding LIKE operator.
- To help debug, I log the originall expression you enter and the SQL part in log file, prefix by MATCH EXPRESSION. You can examine this to see if it works correctly, or if they are not correct, you can send me that info so I can fix. 

- Example: apply match operator on subject field and specify the value 
 
 with (~A ~ B) + {C D} + !E generates this SQL 
 ( ( (issues.subject LIKE '%A%') OR (issues.subject LIKE '%B%') ) AND (issues.subject LIKE '%C D%') AND (issues.subject NOT LIKE '%E%') )
 
 with (A + B) ~ !({C D} +  E) generates 
 (((issues.subject LIKE '%A%') AND (issues.subject LIKE '%B%')) OR  NOT ((issues.subject LIKE '%C D%') AND (issues.subject LIKE '%E%')))
 