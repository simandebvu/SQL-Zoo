-- How many stops are in the database.
 SELECT
    count(name)
FROM
    stops

-- Find the id value for the stop 'Craiglockhart'
SELECT id
FROM stops
WHERE name = 'Craiglockhart'


-- Give the id and the name for the stops on the '4' 'LRT' service.
SELECT id, name
FROM stops JOIN route ON id = route.stop
WHERE route.num = '4' AND route.company = 'LRT'

-- The query shown gives the number of routes that visit either London Road (149) or Craiglockhart (53). Run the query and notice the two services that link these stops have a count of 2. Add a HAVING clause to restrict the output to these two routes.
SELECT company, num, COUNT(*)
FROM route WHERE stop=149 OR stop=53
GROUP BY company, num
HAVING COUNT(*) >= 2;

-- Execute the self join shown and observe that b.stop gives all the places you can get to from Craiglockhart, without changing routes. Change the query so that it shows the services from Craiglockhart to London Road.
SELECT a.company, a.num, a.stop, b.stop
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
WHERE a.stop=53 AND b.stop = 149;

-- The query shown is similar to the previous one, however by joining two copies of the stops table we can refer to stops by name rather than by number. Change the query so that the services between 'Craiglockhart' and 'London Road' are shown. If you are tired of these places try 'Fairmilehead' against 'Tollcross'
SELECT a.company, a.num, stopa.name, stopb.name
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
  JOIN stops stopa ON (a.stop=stopa.id)
  JOIN stops stopb ON (b.stop=stopb.id)
WHERE stopa.name='Craiglockhart' AND stopb.name = 'London Road';

-- Give a list of all the services which connect stops 115 and 137 ('Haymarket' and 'Leith')
SELECT DISTINCT a.company, a.num
FROM route a JOIN route b ON a.company=b.company AND a.num=b.num
WHERE a.stop=115 AND b.stop = 137 OR b.stop=115 AND b.stop = 137;

-- Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'
SELECT DISTINCT a.company, a.num
FROM route a JOIN route b ON a.company = b.company AND a.num = b.num
JOIN stops ax ON ax.id = a.stop
JOIN stops bs ON bs.id = b.stop
WHERE ax.name = 'Craiglockhart' AND bs.name = 'Tollcross' OR bs.name = 'Craiglockhart' AND ax.name = 'Tollcross';


-- Give a distinct list of the stops which may be reached from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. Include the company and bus no. of the relevant services.
SELECT sb.name, a.company, a.num FROM route a
  JOIN route b ON a.company = b.company AND a.num = b.num
  JOIN stops ON a.stop = stops.id
  JOIN stops sb ON b.stop = sb.id
  WHERE stops.name = 'Craiglockhart';

--   Find the routes involving two buses that can go from Craiglockhart to Lochend.
-- Show the bus no. and company for the first bus, the name of the stop for the transfer,
-- and the bus no. and company for the second bus.
SELECT
   a.num AS a_num,
   a.company AS a_company,
   layover.name AS layover_city,
   b.num AS b_num,
   b.company AS b_company 
FROM
   (
      SELECT
         r.* 
      FROM
         route r 
      WHERE
         EXISTS 
         (
            SELECT
               '' 
            FROM
               route r1 
               INNER JOIN
                  stops s 
                  ON ( r1.stop = s.id 
                  AND s.name = 'Craiglockhart' ) 
            WHERE
               r.num = r1.num 
               AND r.company = r1.company 
         )
   )
   a 
   INNER JOIN
      stops layover 
      ON ( a.stop = layover.id ) 
   INNER JOIN
      (
         SELECT
            r.* 
         FROM
            route r 
         WHERE
            EXISTS 
            (
               SELECT
                  '' 
               FROM
                  route r1 
                  INNER JOIN
                     stops s 
                     ON ( r1.stop = s.id 
                     AND s.name = 'Lochend' ) 
               WHERE
                  r.num = r1.num 
                  AND r.company = r1.company 
            )
      )
      b 
      ON ( layover.id = b.stop )