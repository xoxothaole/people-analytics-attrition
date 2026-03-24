-- Q1: Which departments and job roles have the highest attrition rates?
WITH summary AS (
    SELECT
        Department,
        JobRole,
        COUNT(*) AS total_employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
    FROM hr_attrition
    GROUP BY Department, JobRole
)
SELECT
    *,
    ROUND(100.0 * employees_left / total_employees, 1) AS attrition_rate_pct
FROM summary
ORDER BY attrition_rate_pct DESC;

-- Q2: Does overtime correlate with employees leaving? 
WITH summary AS (
    SELECT
        OverTime,
        COUNT(*) AS total_employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
    FROM hr_attrition
    GROUP BY OverTime
)
SELECT
    *,
    ROUND(100.0 * employees_left / total_employees, 1) AS attrition_rate_pct
FROM summary
ORDER BY attrition_rate_pct DESC;

-- Q3: Are employees who haven't been promoted recently more likely to leave?
WITH summary AS (
    SELECT
        CASE
            WHEN YearsSinceLastPromotion = 0  THEN '0 years (recent)'
            WHEN YearsSinceLastPromotion <= 2 THEN '1-2 years'
            WHEN YearsSinceLastPromotion <= 5 THEN '3-5 years'
            ELSE '6+ years'
        END AS years_since_promotion,
        COUNT(*) AS total_employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
    FROM hr_attrition
    GROUP BY years_since_promotion
)
SELECT
    *,
    ROUND(100.0 * employees_left / total_employees, 1) AS attrition_rate_pct
FROM summary
ORDER BY attrition_rate_pct DESC;

-- Q4: How does compensation level relate to attrition risk?
WITH summary AS (
    SELECT
        CASE
            WHEN MonthlyIncome < 3000  THEN 'Under $3K'
            WHEN MonthlyIncome < 6000  THEN '$3K-$6K'
            WHEN MonthlyIncome < 10000 THEN '$6K-$10K'
            ELSE 'Over $10K'
        END AS income_band,
        COUNT(*) AS total_employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS employees_left
    FROM hr_attrition
    GROUP BY income_band
)
SELECT
    *,
    ROUND(100.0 * employees_left / total_employees, 1) AS attrition_rate_pct
FROM summary
ORDER BY attrition_rate_pct DESC;

-- Q5: Who are our highest-flight-risk active employees?
WITH risk_scored AS (
    SELECT
        EmployeeNumber,
        Department,
        JobRole,
        YearsAtCompany,
        MonthlyIncome,
        YearsSinceLastPromotion,
        JobSatisfaction,
        OverTime,
        (
            CASE WHEN OverTime = 'Yes'             THEN 1 ELSE 0 END +
            CASE WHEN YearsSinceLastPromotion >= 3 THEN 1 ELSE 0 END +
            CASE WHEN JobSatisfaction <= 2          THEN 1 ELSE 0 END +
            CASE WHEN MonthlyIncome < 5000          THEN 1 ELSE 0 END +
            CASE WHEN YearsAtCompany < 3            THEN 1 ELSE 0 END
        ) AS risk_score
    FROM hr_attrition
    WHERE Attrition = 'No'
)
SELECT *
FROM risk_scored
WHERE risk_score >= 3
ORDER BY risk_score DESC, YearsSinceLastPromotion DESC;