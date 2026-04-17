--STEP 1. Create Database and Table
-- Connect to the database, then create the table
CREATE TABLE unicorns (
    no INT PRIMARY KEY,
    company VARCHAR(255),
    sector VARCHAR(255),
    entry_valuation_b DECIMAL(10,2),
    valuation_b DECIMAL(10,2),
    entry_date_str VARCHAR(50),
    location VARCHAR(255),
    investors TEXT
);

--STEP 2. Import the CSV file.
--To see the created table by typing the query below and importing the csv file by right clicking unicorns below tables and importing the csv file and also making sure the header is on and the delimiter ','
SELECT * FROM unicorns limit 20


--STEP 3. Data Cleaning
--The dataset has some formatting issues: the "Entry" column is a string (e.g., "Sep/2011"), and company names have symbols like ^ or *. 
-- a. Add a proper Date column and Year column for analysis
ALTER TABLE unicorns ADD COLUMN entry_year INT;

-- b. Extract Year from the entry_date_str (Format: Mon/YYYY)
UPDATE unicorns 
SET entry_year = CAST(SPLIT_PART(entry_date_str, '/', 2) AS INT);

-- c. Clean Company names (Remove ^ and *)
UPDATE unicorns 
SET company = REGEXP_REPLACE(company, '[*^]', '', 'g');

-- d. Simplify Industry names (Optional: grouping sub-sectors)
-- For example, "SaaS - Analytics" becomes "SaaS"
ALTER TABLE unicorns ADD COLUMN main_industry VARCHAR(100);
UPDATE unicorns 
SET main_industry = SPLIT_PART(sector, ' - ', 1);

--STEP 4. Answering Analytical Questions.

--1. How many unicorns were born each year across industries?
SELECT entry_year, main_industry, COUNT(*) as unicorn_count
FROM unicorns
GROUP BY entry_year, main_industry
ORDER BY entry_year DESC, unicorn_count DESC;

--2. Which three industries produced the most unicorns in the past decade?

SELECT main_industry, COUNT(*) as total_unicorns
FROM unicorns
WHERE entry_year >= (EXTRACT(YEAR FROM CURRENT_DATE) - 10)
GROUP BY main_industry
ORDER BY total_unicorns DESC
LIMIT 3;

--3. What is the average valuation by industry and year?

SELECT main_industry, entry_year, 
       ROUND(AVG(valuation_b), 2) as avg_valuation_billions
FROM unicorns
GROUP BY main_industry, entry_year
ORDER BY entry_year DESC, avg_valuation_billions DESC;

--4. Distribution of unicorns by country and industry
--Since the "Location" column often lists "City/Country" (e.g., "Bangalore/Singapore") or just an Indian city, we can assume if a slash exists, the second part is often the international HQ/Country.


SELECT 
    CASE 
        WHEN location LIKE '%/%' THEN SPLIT_PART(location, '/', 2)
        ELSE 'India' 
    END as country,
    main_industry,
    COUNT(*) as count
FROM unicorns
GROUP BY country, main_industry
ORDER BY count DESC;

--5. Which year saw the most unicorns created?

SELECT entry_year, COUNT(*) as total_created
FROM unicorns
GROUP BY entry_year
ORDER BY total_created DESC
LIMIT 1;

--Summary of Insights (Based on Data)
--Top Year: 2021 was a record-breaking year for Indian unicorns.

--Dominant Industries: FinTech and E-commerce consistently lead the rankings.

--Global Presence: While most are based in India, many have dual headquarters in the USA or Singapore, reflecting a trend of "flipping" for better access to global capital.