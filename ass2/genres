#!/usr/bin/python3

# COMP3311 22T3 Assignment 2
# Print a list of countries where a named movie was released

import sys
import psycopg2
import helpers

### Globals

db = None
usage = f"Usage: {sys.argv[0]} Year"

### Command-line args

if len(sys.argv) < 2:
   print(usage)
   exit(1)

# process the command-line args ...
year = sys.argv[1]

### Queries

queryMoviesYear = "select movies.year from movies;"
queryData = f"""
select moviegenres.genre, count(*) as mycount
from movies, moviegenres
where movies.id = moviegenres.movie
and movies.year = '{year}'
group by moviegenres.genre, movies.year
order by mycount desc
FETCH FIRST 10 ROWS WITH TIES;"""

### Manipulating database

try:
   # your code goes here
   db = psycopg2.connect("dbname=ass2")

   if helpers.getYear(year) is None:
      exit("Invalid year")
   
   elif not helpers.checkExistence(db, int(year), queryMoviesYear):
      exit("No movies")

   else:
      res = helpers.getResults(db, queryData)
      for r in res:
            print(f"{r[1]} {r[0]}")

except Exception as err:
   print("DB error: ", err)
finally:
   if db:
      db.close()

