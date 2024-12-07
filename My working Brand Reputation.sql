CREATE DATABASE AfriTechDB;


CREATE TABLE StagingData(
    CustomerID INT,
    CustomerName TEXT,
    Region TEXT,
    Age INT,
    Income NUMERIC(10, 2),
    CustomerType TEXT,
    TransactionYear TEXT,
    TransactionDate DATE,
    ProductPurchased TEXT,
    PurchaseAmount NUMERIC(10, 2),
    ProductRecalled BOOLEAN,
    Competitor TEXT,
    InteractionDate DATE,
    Platform TEXT,
    PostType TEXT,
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    UserFollowers INT,
    InfluencerScore NUMERIC(10, 2),
    BrandMention BOOLEAN,
    CompetitorMention BOOLEAN,
    Sentiment TEXT,
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN,
    NPSResponse INT
);


--Data Modelling
--Use my stagingData table to create the Table I will use.
CREATE TABLE CustomerData(
    CustomerID INT PRIMARY KEY,
	CustomerName VARCHAR(255),
    Region VARCHAR(255),
    Age INT,
    Income NUMERIC(10, 2),
    CustomerType VARCHAR(50)
);


CREATE TABLE Transactions (
    TransactionID SERIAL PRIMARY KEY,
    CustomerID INT,
    TransactionYear VARCHAR(4),
    TransactionDate DATE,
    ProductPurchased VARCHAR(255),
    PurchaseAmount NUMERIC(10, 2),
    ProductRecalled BOOLEAN,
    Competitor VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


CREATE TABLE SocialMedia (
    PostID SERIAL PRIMARY KEY,
    CustomerID INT,
    InteractionDate DATE,
    Platform VARCHAR(50),
    PostType VARCHAR(50),
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    UserFollowers INT,
    InfluencerScore NUMERIC(10, 2),
    BrandMention BOOLEAN,
    CompetitorMention BOOLEAN,
    Sentiment VARCHAR(50),
    Competitor VARCHAR(255),
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN,
    NPSResponse INT,
    FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


-- Insert customer data
INSERT INTO CustomerData (CustomerID, CustomerName, Region, Age, Income, CustomerType)
SELECT DISTINCT CustomerID, CustomerName, Region, Age, Income, CustomerType 
FROM StagingData;


-- Insert transaction data
INSERT INTO Transactions (CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor)
SELECT CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor
FROM StagingData 
WHERE TransactionDate IS NOT NULL;


-- Insert social media data
INSERT INTO SocialMedia (CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse)
SELECT CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares, EngagementComments, UserFollowers, InfluencerScore, BrandMention, CompetitorMention, Sentiment, Competitor, CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse
FROM StagingData 
WHERE InteractionDate IS NOT NULL;


DROP TABLE StagingData;


--Data validation
SELECT COUNT(*)
FROM customerdata;

SELECT COUNT(*)
FROM socialmedia;

SELECT COUNT(*)
FROM transactions;

SELECT *
FROM customerdata
LIMIT 5;

SELECT *
FROM socialmedia
LIMIT 20;

SELECT *
FROM transactions
LIMIT 5;

--identifying missing columns
SELECT COUNT (*)
FROM customerdata
WHERE customerid IS NULL;

SELECT COUNT (*)
FROM socialmedia
WHERE crisiseventtime IS NULL;


--EDA
--Customerdemographics
SELECT region, 
    COUNT (*) AS CustomerCount
FROM customerdata
GROUP BY region;

SELECT COUNT(DISTINCT customerid) AS UniqueCustomers
FROM customerdata;

SELECT 'CustomerName' AS ColumnName, COUNT(*) AS NullCount
FROM CustomerData
WHERE CustomerName IS NOT NULL
UNION
SELECT 'Region' AS ColumnName, COUNT(*) AS NullCount
FROM CustomerData
WHERE Region IS NOT NULL;

--Transactions EDA

SELECT 
    AVG(PurchaseAmount) AS AveragePurchaseAmount,
    MIN(PurchaseAmount) AS MinPurchaseAmount,
    MAX(PurchaseAmount) AS MaxPurchaseAmount,
    SUM(PurchaseAmount) AS TotalSales
FROM Transactions;

--TO_CHAR means to convert numerical value to string. makes the values look like money
SELECT 
    TO_CHAR(AVG(PurchaseAmount), '$999,999,999.99') AS AveragePurchaseAmount,
    TO_CHAR(MIN(PurchaseAmount),'$999,999,999.99')  AS MinPurchaseAmount,
    TO_CHAR(MAX(PurchaseAmount), '$999,999,999.99') AS MaxPurchaseAmount,
    TO_CHAR(SUM(PurchaseAmount), '$9,999,999,999.99') AS TotalSales
FROM Transactions;

--Number of products we have,total amount purchased and total number of sales for each product purchased

SELECT 
    ProductPurchased, 
    COUNT(*) AS NumberOfSales, 
    SUM(PurchaseAmount) AS TotalSales
FROM Transactions
GROUP BY ProductPurchased;

--To see the product purchased that are 'not NULL'

SELECT 
    ProductPurchased, 
    COUNT(*) AS TransactionCount,
    SUM(PurchaseAmount) AS TotalAmount
FROM Transactions
WHERE ProductPurchased IS NOT NULL
GROUP BY ProductPurchased;


SELECT 
    ProductRecalled, 
    COUNT(*) AS TransactionCount,
    AVG(PurchaseAmount) AS AverageAmount
FROM Transactions
WHERE PurchaseAmount IS NOT NULL
GROUP BY ProductRecalled;


--socialmedia EDA
--Average engagement likes and Total engagement likes

SELECT 
    Platform, 
    ROUND(AVG(EngagementLikes),2) AS AverageLikes, 
    ROUND(SUM(EngagementLikes), 2) AS TotalLikes
FROM SocialMedia
GROUP BY Platform;

SELECT 
    Sentiment, 
    COUNT(*) AS Count
FROM SocialMedia
WHERE Sentiment IS NOT NULL
GROUP BY Sentiment;

--Compare sentiment to our platform
SELECT 
    'Platform' AS ColumnName, 
    COUNT(*) AS NullCount
FROM SocialMedia
WHERE Platform IS NOT NULL
UNION
SELECT 
    'Sentiment' AS ColumnName, 
    COUNT(*) AS NullCount
FROM SocialMedia
WHERE Sentiment IS NOT NULL;

--Count the total number of Brand mentions across social media platforms
SELECT platform, COUNT(*) AS VolumeOfMentions
FROM SocialMedia
WHERE brandmention = 'TRUE'
GROUP BY platform;

--Sentiment Score
--Aggregate the sentiment scores:
SELECT Sentiment, 
    COUNT(*) * 100.0 / 
   (SELECT COUNT(*) FROM SocialMedia) AS Percentage
FROM SocialMedia
GROUP BY Sentiment;

--Engagement rate
--Calculate the average engagement rate per post:
SELECT AVG((EngagementLikes + EngagementShares + EngagementComments) / 
	NULLIF(UserFollowers, 0)) AS EngagementRate
FROM SocialMedia;
-- Engagement rate not good at all

--BrandMention by CompetitionMention

SELECT
  SUM(CASE WHEN BrandMention = TRUE THEN 1 ELSE 0 END) AS BrandMentions,
  SUM(CASE WHEN CompetitorMention = TRUE THEN 1 ELSE 0 END) AS CompetitorMentions
FROM SocialMedia;

--Influence Score:
SELECT AVG(InfluencerScore) AS AverageInfluenceScore
FROM SocialMedia;

-- Trend Analysis
--Analyze the trend of mentions over time:
-- that is Monthly trend of brand mentions
SELECT TO_CHAR(DATE_TRUNC('month', InteractionDate), 'YYYY-MM') AS Month, 
   COUNT(*) AS Mentions, platform
FROM SocialMedia
WHERE BrandMention = TRUE
GROUP BY Month, platform;

--Crisis Response Time:
SELECT AVG(DATE_PART('epoch', (CAST(FirstResponseTime AS TIMESTAMP) - CAST(CrisisEventTime AS TIMESTAMP))) / 3600
		  )AS AverageResponseTimeHours
FROM SocialMedia
WHERE CrisisEventTime IS NOT NULL AND FirstResponseTime IS NOT NULL;

SELECT 
    CrisisEventTime, 
    AVG(FirstResponseTime - CrisisEventTime) AS Avg_Response_Time, 
    ResolutionStatus, 
    COUNT(*) AS Crisis_Count
FROM 
    SocialMedia
WHERE 
    CrisisEventTime IS NOT NULL 
GROUP BY 
    CrisisEventTime, 
    ResolutionStatus
ORDER BY 
    Avg_Response_Time ASC;

--Resolution Rate:
SELECT COUNT(*) * 100.0 / 
 (SELECT COUNT(*)
FROM SocialMedia 
  WHERE CrisisEventTime IS NOT NULL) AS ResolutionRate
FROM SocialMedia
 WHERE ResolutionStatus = TRUE;
 
 --Top Influencers and Advocates:
SELECT CustomerID, ROUND(AVG(InfluencerScore),0) AS InfluenceScore
FROM SocialMedia
GROUP BY CustomerID
ORDER BY InfluenceScore DESC
LIMIT 10;

--Content Effectiveness:
SELECT PostType, ROUND(AVG(EngagementLikes + EngagementShares + EngagementComments),0) AS Engagement
FROM SocialMedia
GROUP BY PostType;

-- Total revenue by platform
SELECT
    s.Platform,
    SUM(t.PurchaseAmount) AS TotalRevenue
FROM SocialMedia s
LEFT JOIN Transactions t ON s.CustomerID = t.CustomerID
WHERE t.PurchaseAmount IS NOT NULL
GROUP BY s.Platform
ORDER BY TotalRevenue DESC;

-- Top buying customers
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    COALESCE(SUM(t.PurchaseAmount), 0) AS TotalPurchaseAmount
FROM CustomerData c
LEFT JOIN Transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Region
ORDER BY TotalPurchaseAmount DESC
LIMIT 10; 

-- Average engagement metrics by product
SELECT
    t.ProductPurchased,
    AVG(s.EngagementLikes) AS AvgLikes,
    AVG(s.EngagementShares) AS AvgShares,
    AVG(s.EngagementComments) AS AvgComments
FROM Transactions t
LEFT JOIN SocialMedia s ON t.CustomerID = s.CustomerID
GROUP BY t.ProductPurchased
ORDER BY AvgLikes DESC, AvgShares DESC, AvgComments DESC;

--Products with negative customer buzz and products recalls
WITH NegativeBuzzAndRecalls AS (
    SELECT
        t.ProductPurchased,
        COUNT(DISTINCT CASE WHEN s.Sentiment = 'Negative' THEN s.CustomerID END) AS NegativeBuzzCount,
        COUNT(DISTINCT CASE WHEN t.ProductRecalled = TRUE THEN t.CustomerID END) AS RecalledCount
    FROM Transactions t
    LEFT JOIN SocialMedia s ON t.CustomerID = s.CustomerID
    GROUP BY t.ProductPurchased
)

SELECT
    n.ProductPurchased,
    n.NegativeBuzzCount,
    n.RecalledCount
FROM NegativeBuzzAndRecalls n
WHERE n.NegativeBuzzCount > 0 OR n.RecalledCount > 0;

SELECT 
    NPSResponse, 
    COUNT(ProductPurchased) AS Purchase_Count, 
    AVG(PurchaseAmount) AS Avg_Purchase_Amount
FROM 
    socialmedia
GROUP BY 
    NPSResponse
ORDER BY 
    NPSResponse DESC;

-- Creating a view for brand mentions
CREATE OR REPLACE VIEW BrandMentions AS
SELECT
    InteractionDate,
    COUNT(*) AS BrandMentionCount
FROM SocialMedia
WHERE BrandMention
GROUP BY InteractionDate
ORDER BY InteractionDate;

SELECT * FROM BrandMentions;

- Stored procedure for crisis response time
CREATE OR REPLACE FUNCTION CalculateAvgResponseTime() RETURNS TABLE (
    Platform VARCHAR(50),
    AvgResponseTimeHours NUMERIC
) AS $$
BEGIN
    RETURN QUERY (
        SELECT
            s.Platform,
            AVG(EXTRACT(EPOCH FROM (CAST(s.FirstResponseTime AS TIMESTAMP) - CAST(s.CrisisEventTime AS TIMESTAMP))) / 3600) AS AvgResponseTimeHours
        FROM SocialMedia s
        WHERE s.CrisisEventTime IS NOT NULL AND s.FirstResponseTime IS NOT NULL
        GROUP BY s.Platform
    );
END;
$$ LANGUAGE plpgsql;

SELECT * FROM CalculateAvgResponseTime();


































