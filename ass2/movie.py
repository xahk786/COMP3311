#!/usr/bin/python3

# COMP3311 22T3 Assignment 2
# Print info about one movie; may need to choose

import sys
import psycopg2
import helpers

### Globals

db = None
usage = f"Usage: {sys.argv[0]} 'PartialMovieName'"

### Command-line args

if len(sys.argv) < 2:
   print(usage)
   exit(1)

# process the command-line args ...
searchTerm = sys.argv[1]

### Queries
queryMovie = f"""
select movies.title, movies.year
from movies 
where lower(movies.title) LIKE '%' || lower('{searchTerm}') || '%'
order by title, year;
"""

def queryPrinipals(term):
   return f"""
      select movies.title, people.name, principals.job, principals.ord
      from movies, principals, people
      where principals.movie = movies.id
      and lower(movies.title) LIKE '%' || lower('{term}') || '%'
      and principals.person = people.id
      order by ord;
      """

def queryRole(actor, movie):
   return f"""
      select people.name, playsrole.role, movies.title 
      from playsrole, principals, movies, people
      where people.name = '{actor}' and movies.title = '{movie}'
      and playsrole.inmovie = principals.id 
      and principals.person = people.id 
      and principals.movie = movies.id;
      """

### Manipulating database

try:
   # your code goes here
   db = psycopg2.connect("dbname=ass2")
   resMovies = helpers.getResults(db, queryMovie)
   
   if not resMovies:
      exit(f"No movie matching: '{searchTerm}'")
   else :
      if (len(resMovies) == 1):
         print(f"{resMovies[0][0]} ({resMovies[0][1]})")
      else:
         count = 0
         for r in resMovies:
            count += 1
            print(f"{count}. {r[0]} ({r[1]})")
   
   movieTerm = searchTerm
   if (len(resMovies) > 1):
      index = int(input("Which movie? ")) - 1
      movieTerm = resMovies[index][0]
      movieYear = resMovies[index][1]
      print(movieTerm + f" ({movieYear})")

   resPrincipals = helpers.getResults(db, queryPrinipals(movieTerm))

   for r in resPrincipals:
      if r[2] == 'actor' or r[2] == 'actress' or r[2] == 'self':
         resRoles = helpers.getResults(db, queryRole(helpers.fixString(r[1]), r[0]))
         if (len(resRoles) == 0):
            print(f"{r[1]} plays ???")
         else:
            print(f"{resRoles[0][0]} plays {resRoles[0][1]}")
      else:
         print(f"{r[1]}: {r[2]}")

except Exception as err:
   print("DB error: ", err)
finally:
   if db:
      db.close()

