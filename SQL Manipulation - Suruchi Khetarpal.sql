-----q1
---Find the number of classes (using classID in count) in the Classes table as class_count
---grouped by the CategoryDescription field in the Categories table as category_name. Only 
---return a single record (or row) from a grouping of rows with the same class_count.
---Sort by the class_count descending and category_name ascending. Limit to 5 results.

---table hints:  Categories, Subjects, Classes


Select distinct on (count(cls.classid)) count(cls.classid) as class_count
	 ,cat.categorydescription as category_name
     from classes as cls join subjects as sub using (subjectid)
	 join categories as cat using (categoryid)
     group by (categorydescription)
     order by count(classID) desc, category_name asc
     limit 5


---q2
---Find the number of distinct classes (using the ClassID key in the count) from the Faculty_Classes table as class_count
---and the number of distinct subjects (using SubjectID in the count) as subject_count for each person in the Staff table 
---even if they have no classes or subjects. Return the StfFirstName, StfLastname, Position, DateHired (all Staff table), 
---and the Title (Faculty table). However, from these results, only return a single record (or row) 
---from a grouping of rows with the same class_count. 
---Sort by the class_count and Title both ascending, and DateHired descending. 
---Limit to 6 results.


Select distinct on (class_count) stf.StfFirstName, stf.StfLastname, stf.staffid, stf.Position, fac.Title, stf.DateHired
	, count(distinct(fcls.classid)) as class_count
	, count (distinct (sub.subjectid)) as subject_count
    from staff stf
	left join faculty_subjects fsub using (staffid)
	join faculty fac using (staffid)
	left join faculty_classes fcls using (staffid)
	left join subjects sub using (subjectid)
	group by stf.StfFirstName, stf.stflastname, stf.Position, stf.DateHired, fac.title, stf.staffid
    order by class_count, Title, DateHired desc
    limit 6

---q3
---Find the number of distinct movies (by movie_id in the movies_actors table) as total_movies,
---number of actors (by actor_id in the movies_actors table) as total_actors, the sum of 
---the revenues_domestic (movies_revenues table) as dom_rev for each director in the Directors table by first_name 
---and last_name. Only return groupings that have a total_movies value equal to 1. From these results,
---return a single record (or row) from a grouping of rows with the same number of total_actors. 

---Sort by the total_actors descending, dom_rev descending, and last_name desc.


---table hints: directors, movies,  movies_revenues, movies_actors

Select distinct on (total_actors) count(distinct(mov.movie_id)) as total_movies
	, first_name, last_name, count(mac.actor_id) as total_actors
	, sum(movr.revenues_domestic) as dom_rev
	from movies_actors mac join movies mov using (movie_id)
	join directors dir using (director_id)
	join movies_revenues movr using (movie_id)
    group by first_name, last_name
    having count(distinct(mov.movie_id)) = 1
    order by total_actors desc, dom_rev desc, last_name desc
	

---q4
---Find the sum of the revenues_domestic plus the revenues_international as total_value grouped by the 
---director_name and actor_name where the revenues_domestic is not null and the revenues_international is not null.
---Sort by the total_value descending and the director_name descending. Limit to 4 results.
---director_name = is the first_name concatenated with the last_name field from the Directors table as so 'first_name, last_name'

---actor_name = is the first_name concatenated with the last_name field from the Actors table as so 'first_name, last_name'

---table hints: directors, movies, movie_actors, actors, movies_revenues

Select (dir.first_name ||', '|| dir.last_name ) as director_name
	, (act.first_name ||', '|| act.last_name) as actor_name
	, sum(revenues_domestic + revenues_international) as total_value
    from directors dir
	join movies mov using (director_id)
	join movies_revenues movr using (movie_id)
	join movies_actors mac using (movie_id) 
	join actors act using (actor_id)
    where revenues_domestic IS NOT NULL and revenues_international IS NOT NULL
    group by director_name, actor_name
    order by total_value desc, director_name desc
    limit 4 


---q5
---Find the distinct number of classes (using ClassID in the count) and total number of students (using StudentID)
---even if there are no students, grouped by SubjectName from the Subjects table. Return subjects where there is 
---not a faculty for that subject - in other words, where the Subjects table SubjectID is not in the Faculty_Subjects table.

--- table hints: Subjects, Classes, Student_Schedules, Faculty_Subjects

Select sub.SubjectName, count(distinct cls.ClassID) as class_count, count(schedule.StudentID) as student_count
    from classes cls
	left join student_schedules schedule using (ClassID)
	left join subjects sub using (SubjectID)
	left join faculty_subjects fsub using (SubjectID)
    where fsub.subjectid IS NULL
    group by subjectname


---q6
---Find the number of classes as class_count from the Classes table grouped by SubjectName
---where the ClassID is in ClassIDs that have a ClassStatusDescription value of 'Completed' and 
---the SubjectName has the word 'fundamental' (case-insensitive) somewhere in it.

---Note: To see if a class has a value of 'Completed' , you must join the Student_Schedules table 
---and the Student_Class_Status table, and filter on where the ClassStatusDescription(Student_Class_Status table)
---value is equal to 'Completed'.

---table hints: Subjects, Classes, Student_Schedules, Student_Class_Status

Select sub.SubjectName, count(distinct cls.ClassID) as class_count
	from classes cls 
	join student_schedules studs using (ClassID)
	join student_class_status studcs using (ClassStatus)
	join subjects sub using (SubjectID)
    where ClassStatusDescription = 'Completed' and subjectname ilike '%fundamental%'
    group by subjectname


---q7
---Find the total number of students as student_count grouped by Major (Majors table) 
---and ClassStatusDescription (Student_Class_Status table) sorted by student_count descending and Major ascending. 
---Limit to 4 results.

---table hints: Majors, Students, Student_Schedules, Student_Class_Status, Classes

Select maj.Major, studcs.ClassStatusDescription, count(stu.studentID) as student_count
    from students stu join majors maj on stu.studmajor = maj.majorID
	join student_schedules studs using (studentID) join student_class_status studcs using (classstatus)
    group by majorID, ClassStatusDescription
    order by student_count desc, major asc
    limit 4

---q8
---Find the sum of quantity (the order_details table) as total_quantity, the total number of orders as 
---total_orders grouped by Company_Name (Customers table) and by the year of the Order_Date (Orders table)
---as order_year (you must extract(field from source) to retrieve the year). Filter on where the 
---Country field (Customers table) value is equal to the 'UK'. Return groups having a total_orders
---value greater than 10. Sort by total_quantity descending and total_orders descending.

---Table hints: Customers, Orders, Order_Details

Select Company_Name, Date_Part('YEAR', order_date) as order_year, sum(quantity) as total_quantity
       , count(order_id) as total_orders
       from order_details join orders using (order_id)
       join customers using (customer_id)
       where country = 'UK'
       group by (company_name), Date_Part('YEAR', order_date)
       having count(order_id) > 10
       order by total_quantity desc, total_orders desc
