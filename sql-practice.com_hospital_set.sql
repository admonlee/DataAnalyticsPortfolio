/*
My solutions to questions on sql-practice.com
*/


-- Q1
SELECT first_name, last_name, gender 
FROM patients 
WHERE gender LIKE 'M';

-- Q2
SELECT first_name, last_name 
FROM patients 
WHERE allergies IS NULL;

-- Q3
SELECT first_name
FROM patients
WHERE first_name LIKE 'C%';

-- Q4
SELECT first_name, last_name
FROM patients
WHERE weight >= 100 AND weight <= 120;

-- Q5
UPDATE patients
SET allergies='NKA'
WHERE allergies IS NULL;

-- Q6
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM patients;

-- Q7
SELECT first_name, last_name, province_name
FROM patients
JOIN province_names
  ON patients.province_id = province_names.province_id;

-- Q8
SELECT COUNT(birth_date)
FROM patients
WHERE YEAR(birth_date) = 2010;

-- Q9
SELECT first_name, last_name, height
FROM patients
WHERE height = (SELECT MAX(height) FROM patients);

-- Q10
SELECT *
FROM patients
WHERE patient_id in (1, 45, 534, 879, 1000);

-- Q11
SELECT count(*)
FROM admissions;

-- Q12
SELECT *
FROM admissions
WHERE admission_date = discharge_date;

-- Q13
SELECT COUNT(admission_date), patient_id
from admissions
where patient_id = 579;

-- Q14
SELECT DISTINCT city
FROM patients
WHERE province_id = 'NS';

-- Q15
SELECT first_name, last_name, birth_date
FROM patients
WHERE height > 160 AND weight > 70;

-- Q16
SELECT first_name, last_name, allergies
FROM patients
where city LIKE 'Hamilton' and allergies IS NOT NULL;

-- Q17
SELECT distinct city
FROM patients
WHERE city LIKE 'A%'
    OR city LIKE 'E%'
    OR city LIKE 'I%'
    OR city LIKE 'O%'
    OR city LIKE 'U%'
ORDER BY city;

-- Q18
SELECT DISTINCT CAST(birth_date as date)
FROM patients 
ORDER BY birth_date ASC;

-- Q19
SELECT first_name
FROM patients
group by first_name
HAVING count(first_name)=1;

-- Q20
SELECT patient_id, first_name
FROM patients
WHERE first_name like 'S%s'
	AND LEN(first_name) >=6;

-- Q21
SELECT DISTINCT patients.patient_id, first_name, last_name
FROM patients
JOIN admissions
ON	patients.patient_id=admissions.patient_id AND
	admissions.diagnosis='Dementia';

-- Q22
SELECT first_name
FROM patients
order by len(first_name), first_name;

-- Q23
SELECT *
FROM (SELECT COUNT(*) FROM patients WHERE gender = 'M') AS male_count,
	(SELECT COUNT(*) FROM patients WHERE gender = 'F') AS female_count;

-- Q24
SELECT first_name, last_name, allergies
FROM patients
WHERE allergies in ('Penicillin', 'Morphine')
group by allergies, first_name, last_name;

-- Q25
SELECT patient_id, diagnosis
from admissions
GROUP BY patient_id, diagnosis
HAVING COUNT(*) > 1;

-- Q26
SELECT City, COUNT(*) as total_patients
FROM patients
GROUP BY City
order by total_patients DESC, city;

-- Q27
SELECT first_name, last_name, 'Patient' as role FROM patients
UNION ALL
SELECT first_name, last_name, 'Doctor' as role FROM doctors;

-- Q28
SELECT distinct allergies, COUNT(allergies)
FROM patients
WHERE allergies IS NOT NULL
GROUP BY allergies
ORDER BY COUNT(allergies) DESC;

-- Q29
SELECT first_name, last_name, birth_date
FROM patients
WHERE YEAR(birth_date)>=1970 AND year(birth_date)<=1979
ORDER BY birth_date;

-- Q30
SELECT CONCAT(UPPER(last_name),',',lower(first_name))
FROM patients
ORDER BY first_name DESC;

-- Q31
SELECT province_id, SUM(height)
FROM patients
GROUP BY province_id
HAVING SUM(height) >= 7000;

-- Q32
SELECT (max(weight)-MIN(weight)) AS difference
FROM patients
WHERE last_name = "Maroni";

-- Q33
SELECT (Day(admission_date)) AS admission_day, COUNT(admission_date) AS total
FROM admissions
GROUP BY admission_day
ORDER BY total DESC;

-- Q34
SELECT *
FROM admissions
WHERE patient_id = 542 AND
	admission_date IN 
    (SELECT MAX(admission_date) FROM admissions WHERE patient_id = 542);

-- Q35
SELECT patient_id, attending_doctor_id, diagnosis
from admissions
where (MOD(patient_id, 2) != 0 AND attending_doctor_id in (1,5,19))
	OR (CAST(attending_doctor_id AS varchar) LIKE "%2%" AND len(patient_id) = 3);

-- Q36
SELECT doctors.first_name, doctors.last_name, COUNT(admissions.admission_date) as total_admissions
FROM admissions
JOIN doctors
ON admissions.attending_doctor_id = doctors.doctor_id
group by doctors.doctor_id;

-- Q37
SELECT CONCAT(first_name, " ", last_name), doctor_id, 
		MIN(admission_date) AS first_admission, MAX(admission_date) AS last_admission
FROM doctors
JOIN admissions
ON doctor_id = attending_doctor_id
GROUP BY doctor_id;

-- Q38
SELECT COUNT(patient_id) AS total_patients, province_name
FROM patients
JOIN province_names
ON patients.province_id = province_names.province_id
group by province_name
ORDER BY total_patients DESC;

-- Q39
SELECT CONCAT(patients.first_name, ' ', patients.last_name) AS full_name, admissions.diagnosis,
		CONCAT(doctors.first_name, ' ', doctors.last_name) as doctors_name
FROM patients
JOIN admissions
	ON patients.patient_id = admissions.patient_id
JOIN doctors
	on admissions.attending_doctor_id = doctors.doctor_id;

-- Q40
SELECT first_name, last_name, COUNT(*) AS num_of_duplicates
FROM patients
GROUP BY first_name, last_name
HAVING num_of_duplicates > 1;

-- Q41
SELECT CONCAT(first_name, ' ', last_name), ROUND(height/30.48, 1),
	ROUND(weight*2.205, 0), birth_date, CASE
    WHEN gender = 'M' THEN 'MALE'
    WHEN gender = 'F' THEN 'FEMALE'
    ELSE 'The quantity is under 30'
END AS gender_type
FROM patients;

-- Q42
SELECT COUNT(*) as patients_in_group, TRUNCATE(weight, -1) AS weight_group
FROM patients
GROUP BY weight_group
ORDER BY weight_group DESC;

-- Q43
SELECT patient_id, weight, height,
	CASE
	  WHEN (weight/SQUARE(height/100.0)) >= 30 THEN 1
        ELSE 0
    END AS isObese
FROM patients;

-- Q44
SELECT p.patient_id, p.first_name, p.last_name, d.specialty
FROM patients AS p 
JOIN admissions AS a 
	ON p.patient_id = a.patient_id
JOIN doctors AS d 
	ON a.attending_doctor_id = d.doctor_id
WHERE
	a.diagnosis = 'Epilepsy'
    AND d.first_name = 'Lisa';

-- Q45
SELECT DISTINCT p.patient_id, CONCAT(p.patient_id, LEN(p.last_name), YEAR(p.birth_date))
FROM patients p
JOIN  admissions a 
	ON p.patient_id = a.patient_id;

-- Q46
SELECT 
  CASE WHEN patient_id % 2 = 0 Then 'Yes'
    ELSE 'No' 
  END AS has_insurance,
  SUM(CASE WHEN patient_id % 2 = 0 Then 10
	ELSE 50 
	END) AS cost_after_insurance
FROM admissions 
GROUP BY has_insurance;

-- Q47
SELECT province_name 
FROM
 (SELECT province_name, MAX(gender_count), gender 
  FROM
	(SELECT province_name, gender, count(gender) AS gender_count
	FROM patients
	JOIN province_names
	ON patients.province_id = province_names.province_id
	group by patients.province_id, gender)
  GROUP BY province_name)
WHERE gender = 'M';

-- Q48
SELECT *
FROM patients
WHERE first_name LIKE '__r%'
	AND gender = 'F'
    AND month(birth_date) in (2,5,12)
    AND weight > 60
    AND weight < 80
    and MOD(patient_id,2) != 0
    AND city = 'Kingston';

-- Q49
SELECT CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*)*1.0 FROM patients)*100, 2), '%')
FROM patients
WHERE gender = 'M';

-- Q50
SELECT admission_date, admission_day, 
	admission_day - lag(admission_day) OVER(ORDER BY admission_date) AS admission_count_change
FROM
(SELECT admission_date, COUNT(*) as admission_day	
 FROM admissions
 GROUP BY admission_date);

-- Q51
SELECT admission_date, admission_day, 
	admission_day - lag(admission_day) OVER(ORDER BY admission_date) AS admission_count_change
FROM
(SELECT admission_date, COUNT(*) AS admission_day	
 FROM admissions
 GROUP BY admission_date);