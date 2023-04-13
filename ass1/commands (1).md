
p0
p1
dropdb ass1
createdb ass1
psql ass1 -f ass1.dump > log 2>&1
psql ass1 -f ass1.sql
psql ass1 -f /home/cs3311/web/22T3/assignments/ass1/check.sql
source /localstorage/$USER/env

notes:
- https://lukakerr.github.io/uni/3311-notes

ssh nw-syd-vxdb2

http://www.cse.unsw.edu.au/~cs3311/22T3/exams/22T3/index.html


-SqlQueries 

-SqlFunctions 
    - create sql query helper 
    - then create function to find the row of the helper query 

-Plpgsql
    - create sql query helper 
    - declare r RECORd variable (row of the helper query)
    - declare out variable (output of the function)
    - find the r of interest using for r in (helper query) 
        - either through the loop statement in plpgsql
        - or the where clause in helper function
    
    


Final exam commands on linux computer: 

- connect to sql server : 
    ssh nw-syd-vxdb2
    psql -l 
    psql [db]

- set environment variables: 
    source /localstorage/$USER/env

- create db and load dump file in 

- load sql file in 

- if errors like alter drop view column etc... remake the data base and load all info back in 

p0
p1
source /localstorage/$USER/env
drop dp racing 
createdb racing 
psql racing -f racing.dump
psql racing -f racingQueries.sql