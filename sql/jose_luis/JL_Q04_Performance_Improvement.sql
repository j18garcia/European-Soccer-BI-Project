
-- ============================================================
-- CAP2761C - European Soccer BI Project
-- Author: Jose Luis Garcia
-- Query: JL-Q04 - Performance Improvement
-- ============================================================

-- Business Question:
-- Which teams showed the greatest improvement in performance
-- between the first and last seasons (2011/12 to 2015/16)?

-- Business Objective:
-- Identify clubs with improving sporting performance
-- as preliminary candidates for sponsorship evaluation.

-- Analysis Criteria:
-- 1. England, Germany, and Spain.
-- 2. Compare 2011/2012 against 2015/2016.
-- 3. Include teams with at least three seasons of data.
-- 4. Require participation in both comparison seasons.
-- 5. Rank teams by improvement in points per match.

;WITH MatchPoints AS (

    -- Step 1: Calculate home team points.
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

    -- Step 2: Calculate away team points.
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

    -- Step 3: Calculate PPM per team and season.
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
),
TeamImprovement AS (

    -- Step 4: Compare first and last season PPM.
    SELECT
        league_id,
        team_id,
        COUNT(*) AS seasons_played,

        MAX(CASE WHEN season_id = 2011
            THEN ppm END) AS first_season_ppm,

        MAX(CASE WHEN season_id = 2015
            THEN ppm END) AS last_season_ppm

    FROM SeasonPerformance
    GROUP BY
        league_id,
        team_id
    HAVING
        COUNT(*) >= 3
)

-- Step 5: Calculate and rank improvement.
SELECT
    l.league_name,
    t.team_long_name,
    ti.seasons_played,

    CAST(ti.first_season_ppm AS DECIMAL(5,2))
        AS first_season_ppm,

    CAST(ti.last_season_ppm AS DECIMAL(5,2))
        AS last_season_ppm,

    CAST(
        ti.last_season_ppm - ti.first_season_ppm
        AS DECIMAL(5,2)
    ) AS ppm_improvement

FROM TeamImprovement ti

INNER JOIN dbo.Team t
    ON ti.team_id = t.team_id

INNER JOIN dbo.League l
    ON ti.league_id = l.league_id

WHERE
    ti.first_season_ppm IS NOT NULL
    AND ti.last_season_ppm IS NOT NULL

ORDER BY
    ppm_improvement DESC,
    t.team_long_name ASC;
