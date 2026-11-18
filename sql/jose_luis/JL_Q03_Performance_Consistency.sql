
-- ============================================================
-- CAP2761C - European Soccer BI Project
-- Author: Jose Luis Garcia
-- Query: JL-Q03 - Performance Consistency
-- ============================================================

-- Business Question:
-- Which teams maintained the most consistent performance
-- across multiple seasons?

-- Business Objective:
-- Identify clubs with stable and competitive performance
-- across at least three seasons to support preliminary
-- sponsorship and advertising opportunity screening.

-- Analysis Criteria:
-- 1. Include England, Germany, and Spain.
-- 2. Analyze seasons from 2011/2012 to 2015/2016.
-- 3. Require participation in at least three seasons.
-- 4. Require average points per match of at least 1.50.
-- 5. Measure consistency using the difference between
--    the highest and lowest season PPM.
-- 6. A smaller PPM range indicates greater consistency.

;WITH MatchPoints AS (

    -- Step 1: Calculate points earned at home.
    SELECT
        league_id,
        season_id,
        home_team_id AS team_id,
        CASE
            WHEN home_team_goal > away_team_goal THEN 3
            WHEN home_team_goal = away_team_goal THEN 1
            ELSE 0
        END AS points
    FROM dbo.[Match]

    UNION ALL

    -- Step 2: Calculate points earned away.
    SELECT
        league_id,
        season_id,
        away_team_id AS team_id,
        CASE
            WHEN away_team_goal > home_team_goal THEN 3
            WHEN away_team_goal = home_team_goal THEN 1
            ELSE 0
        END AS points
    FROM dbo.[Match]
),
SeasonPerformance AS (

    -- Step 3: Calculate points per match for each
    -- team within each league and season.
    SELECT
        league_id,
        season_id,
        team_id,
        SUM(points) * 1.0 / COUNT(*) AS ppm
    FROM MatchPoints
    GROUP BY
        league_id,
        season_id,
        team_id
)

-- Step 4: Evaluate consistency across seasons.
SELECT
    l.league_name,
    t.team_long_name,
    COUNT(*) AS seasons_played,

    CAST(AVG(sp.ppm) AS DECIMAL(5,2))
        AS avg_points_per_match,

    CAST(MIN(sp.ppm) AS DECIMAL(5,2))
        AS lowest_season_ppm,

    CAST(MAX(sp.ppm) AS DECIMAL(5,2))
        AS highest_season_ppm,

    CAST(MAX(sp.ppm) - MIN(sp.ppm) AS DECIMAL(5,2))
        AS ppm_range

FROM SeasonPerformance sp

INNER JOIN dbo.Team t
    ON sp.team_id = t.team_id

INNER JOIN dbo.League l
    ON sp.league_id = l.league_id

GROUP BY
    l.league_name,
    t.team_long_name

HAVING
    COUNT(*) >= 3
    AND AVG(sp.ppm) >= 1.50

ORDER BY
    ppm_range ASC,
    avg_points_per_match DESC,
    t.team_long_name ASC;
