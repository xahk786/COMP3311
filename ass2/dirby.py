#!/usr/bin/python3

# COMP3311 22T3 Assignment 2
# Print a list of movies directed by a given person

import sys
import psycopg2
import helpers

### Globals

db = None
usage = f"Usage: {sys.argv[0]} FullName"

### Command-line args

if len(sys.argv) < 2:
   print(usage)
   exit(1)

# process the command-line args ...
person = sys.argv[1]

### Queries
queryPerson = "select people.name from people;"

queryDirector = "select people.name from people, principals where people.id = principals.person and principals.job = 'director';"

queryData = "select people.name, movies.title, movies.year from people, movies, principals where people.id = principals.person and principals.movie = movies.id and principals.job = 'director' order by year;"
### Manipulating database

try:
   # your code goes here
   db = psycopg2.connect("dbname=ass2")

   if not helpers.checkExistence(db, person, queryPerson):
      exit("No such person")
   
   elif not helpers.checkExistence(db, person, queryDirector):
      count = helpers.getPeopleCount(db, person)
      if (count > 1):
         exit(f"None of the people called {person} has directed any films")
      else:
         exit(f"{person} has not directed any movies")
   
   else:
      res = helpers.getResults(db, queryData)
      for r in res:
         if r[0] == person:
            print(f"{r[1]} ({r[2]})")


except Exception as err:
   print("DB error: ", err)
finally:
   if db:
      db.close()

