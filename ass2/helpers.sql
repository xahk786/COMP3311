-- COMP3311 21T3 Ass2 ... extra database definitions
-- add any views or functions you need into this file
-- note: it must load without error into a freshly created Movies database
-- you must submit this file even if you add nothing to it

-- Derby:

-- check if person exists 
select people.name 
from people;


-- check if person directed is director films 
select people.name 
from people, principals
where people.id = principals.person 
and principals.job = 'director';

select people.name, principals.job 
from people, principals
where people.id = principals.person
and people.name = 'Kevin Jones';

select people.name, principals.job 
from people, principals
where people.id = principals.person
and people.name = 'Nicole Kidman';

select people.name 
from people
where people.name = 'Kevin Jones';


-- data required 
select people.name, movies.title, movies.year
from people, movies, principals 
where people.id = principals.person 
and principals.movie = movies.id
and principals.job = 'director'
and people.name = 'James Cameron';

--Releases 

--check movie 
select movies.title
from movies;

--check releases
select movies.title
from movies, releasedin
where releasedin.movie = movies.id;

--data required 
select movies.title, movies.year, countries.name
from movies, releasedin, countries 
where releasedin.movie = movies.id
and releasedin.country = countries.code;

--Genres 

-- select movies.title, moviegenres.genre
-- from movies, moviegenres
-- where movies.id = moviegenres.movie;

--movies in a given year 
select movies.year
from movies;
order by movies.year

--data required 
select moviegenres.genre, movies.year, count(*) as mycount
from movies, moviegenres
where movies.id = moviegenres.movie
group by moviegenres.genre, movies.year
order by mycount desc
FETCH FIRST 10 ROWS WITH TIES;

-- select moviegenres.genre, count(*) as mycount
-- from movies, moviegenres
-- where movies.id = moviegenres.movie
-- and movies.year = '1990'
-- group by moviegenres.genre, movies.year
-- order by mycount desc
-- FETCH FIRST 10 ROWS WITH TIES;

--roles

--data required 

select people.name, playsrole.role, movies.title, movies.year, people.id
from  playsrole,  movies, principals, people
where people.name = 'Steve Jones'  
and playsrole.inmovie = principals.id  
and principals.movie = movies.id
and principals.person = people.id
order by id, year, title, role;

select people.name, playsrole.role, movies.title, movies.year, people.id
from  playsrole,  movies, principals, people
where people.name = 'Clint Eastwood'
and playsrole.inmovie = principals.id  
and principals.movie = movies.id
and principals.person = people.id
and playsrole.role != 'Self'
order by id, year, title, role;

--testing 
select people.name , principals.job, principals.movie
from people, principals
where principals.person = people.id
and people.name = 'Steve Jones' and principals.job = 'self';

--first do a normal search 
select people.name, people.id
from people
where people.name = 'Steve Jones'
order by id;

--if shows up in normal people search, do this and output the data. If data 0 rows then no acting roles 
select people.id, people.name, playsrole.role, movies.title, movies.year
from  playsrole,  movies, principals, people
where people.id = '1112001'
and playsrole.inmovie = principals.id
and principals.movie = movies.id
and principals.person = people.id
order by year, title, role;

select people.name, people.id, playsrole.role
from people, principals, playsrole
join principals 
on (playsrole.inmovie).person = people.id
where people.name = 'Steve Jones'
order by id;

--movie script 

select movies.title, movies.year
from movies 
where lower(movies.title) LIKE '%' || lower('ooo') || '%'
order by title, year;

select movies.title, people.name, principals.job, principals.ord
from movies, principals, people
where principals.movie = movies.id
and lower(movies.title) LIKE '%' || lower('The Jeffrey Dahmer Files') || '%'
and principals.person = people.id
order by ord;

select movies.title, people.name, principals.job, playsrole.role, principals.ord
from movies, principals, people, playsrole
where principals.movie = movies.id
and lower(movies.title) LIKE '%' || lower('avatar') || '%'
and principals.person = people.id
and principals.id = playsrole.inmovie
order by ord;

select people.name, playsrole.role, movies.title 
from playsrole, principals, movies, people
where people.name = 'Chris O''Dowd' and movies.title = 'The Sapphires'
and playsrole.inmovie = principals.id 
and principals.person = people.id 
and principals.movie = movies.id;