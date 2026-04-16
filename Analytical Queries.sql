--count of each occupation
SELECT Occupation ,COUNT(Occupation) AS NumOfOccupation
FROM CreditScoreTable
GROUP BY Occupation
ORDER BY NumOfOccupation DESC;

--ranking avg income of each occupation
SELECT Occupation, AVG(Annual_Income) AS AvgIncome, DENSE_RANK() OVER(ORDER BY
AVG(Annual_Income) DESC) AS [Rank]
FROM CreditScoreTable
GROUP BY Occupation;

--part-to-whole analysis, comparing individuals in each occupation income with the avg income
SELECT Occupation, Annual_Income, AVG(Annual_Income) OVER (PARTITION BY Occupation) AS AvgIncome
FROM CreditScoreTable
ORDER BY Occupation, Annual_Income DESC;

--count of credit score
SELECT Credit_Score, COUNT(*) AS NumOfCreditScore
FROM CreditScoreTable
GROUP BY Credit_Score;

--dividing data into groups ordrerd by debt then seeing if high debt means poor score
WITH DebtTable AS 
(
SELECT Outstanding_Debt, Credit_Score, NTILE(10) OVER(ORDER BY Outstanding_Debt DESC) AS GroupNum
FROM CreditScoreTable
)
SELECT GroupNum, SUM(CASE WHEN Credit_Score = 'Poor' THEN 1 ELSE 0 END) AS NumOfPoorScore, 
SUM(CASE WHEN Credit_Score = 'Good' THEN 1 ELSE 0 END) AS NumOfGoodScore
FROM DebtTable
GROUP BY GroupNum;

--getting num of poor credit score per occupation and trying to see if there a relation 
--to avg annual income per occupation
SELECT Occupation, SUM(CASE WHEN Credit_Score = 'Poor' THEN 1 ELSE 0 END) AS NumOfPoorScore, 
AVG(Annual_Income) AS AvgIncome
FROM CreditScoreTable
GROUP BY Occupation
ORDER BY NumOfPoorScore DESC;

--rank customers based on how much they pay back montly
SELECT Credit_Score, Total_EMI_per_Month, 
DENSE_RANK() OVER(PARTITION BY Credit_Score ORDER BY Total_EMI_per_Month DESC)
AS [Rank]
FROM CreditScoreTable;

--running total analysis on num_loan
WITH CumlativeLoans AS
(
SELECT Age, Occupation, SUM(Num_Of_Loan)
OVER(PARTITION BY Occupation ORDER BY Age, Outstanding_Debt DESC 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS AccumulatedLoans
FROM CreditScoreTable
)
SELECT Age, AVG(AccumulatedLoans * 1.0) AS AvgLoans,
LAG(AVG(AccumulatedLoans * 1.0), 1, 0) OVER(ORDER BY AGE)AS PrevAgeAvg,
AVG(AccumulatedLoans * 1.0) - LAG(AVG(AccumulatedLoans * 1.0),1 , 0)
OVER(ORDER BY AGE) AS YearlyGrowth,
CASE WHEN (LAG(AVG(AccumulatedLoans * 1.0),1 , 0) OVER(ORDER BY AGE)) = 0 THEN 0 ELSE 
((AVG(AccumulatedLoans * 1.0) - LAG(AVG(AccumulatedLoans * 1.0),1 , 0) OVER(ORDER BY AGE))
/LAG(AVG(AccumulatedLoans * 1.0),1 , 0) OVER(ORDER BY AGE)) * 100 END
AS YearlyGrowthPercentage
FROM CumlativeLoans
GROUP BY AGE
ORDER BY AGE;
