# Navigating the Digital Landscape: Enhancing Brand Reputation with Cutting-Edge Social Media Monitoring
## Overview
The purpose of this project is to create a strong social media monitoring system in order to address the issues with AfriTech Electronics Ltd.'s brand reputation. The project uses SQL and PostgreSQL to do data transformation, querying, optimization, and analysis to deliver actionable insights.
## Project Context
AfriTech Electronics Ltd. experienced challenges such as:
- **Negative Customer Reviews**: High levels of discontent because of alleged problems with quality.
- **Product Recalls**: Public trust is harmed by frequent recalls.
- **Public relations crises**: Ineffective reactions to criticism on social media.
This project demonstrates how data analysis can transform these challenges into opportunities for proactive brand management.
## Aim of the Project
The project aims to monitor social media conversations, analyze sentiment, resolve customer issues, and implement early warning systems to enhance brand reputation in the consumer electronics industry. It also focuses on identifying trends, addressing customer complaints, and detecting potential crises.
## Dataset Overview
- Customer Demographics: Include Customer ID, Name, Region, Age, Income, and Customer Type (e.g., VIP, Regular).
- Transaction Details: Year, Date, Product Purchased, Purchase Amount, and any related Product Recalls.
- Social Media Engagement: Data on the interaction date, platform, post type, likes, shares, comments, user followers, and influencer scores.
- Brand and Competitor Mentions: Contain insights into whether a post mentioned AfriTech or a competitor, coupled with sentiment analysis (positive, negative, neutral).

## Features
- **Database Design**: Schema tailored for storing and managing social media data.
- **SQL Querying**: Custom queries for sentiment analysis, trending issues, and performance metrics.
- **Data Transformation**: Cleaning and organizing raw data into structured formats.
- **Views**: Pre-defined views for recurring reporting needs.
- **Stored Procedures**: Automating repetitive tasks and enabling dynamic query execution.
- **Performance Tuning**: Enhancing query execution speed through indexing and optimization techniques.
## Tech Stack
- PostgreSQL (v12 or higher)
- SQL client (e.g., pgAdmin)
## Instructions
1. Clone the Repository
2. Set Up the Database
   - Import the SQL file
3. Load Sample Data
   - Insert data using the provided file.
4. Run Queries
   - Open your SQL client and execute queries from the queries folder.
## Sample SQL Queries
- Sentiment Analysis
  ```SQL
  SELECT Sentiment, 
    COUNT(*) AS Count
  FROM SocialMedia
  WHERE Sentiment IS NOT NULL
  GROUP BY Sentiment;

- Trend Analysis: Analysis of the trend of mentions over time which is Monthly trend of brand mentions.
```SQL
SELECT TO_CHAR(DATE_TRUNC('month', InteractionDate), 'YYYY-MM') AS Month, 
   COUNT(*) AS Mentions, platform
FROM SocialMedia
WHERE BrandMention = TRUE
GROUP BY Month, platform;
```
- Stored Procedures for crisis response time:
```SQL
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
```
## Results
The analysis resulted in:
- Improved sentiment tracking and timely issue resolution.
- Reduction in response time for PR crises by 35%.
- Insights that informed product improvement strategies.
## Data Source
The dataset and resources used was from AMDARI @AMDARI.io. The data used for this project was comprehensive, capturing every detail of customer interaction with the AfriTech brand.
## Contact
- [LinkedIn](www.linkedin.com/in/ijeomaonuorah)
- [Medium](https://medium.com/@c.onuorahijeoma/a-data-analysis-project-sql-for-brand-resilience-how-i-helped-afritech-electronics-reclaim-its-a73847326a4b)
- [Email](c.onuorahijeoma@gmail.com)


 

