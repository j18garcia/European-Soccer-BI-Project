
-- CAP2761C - European Soccer BI
-- Author: Jose Luis Garcia
-- Query: JL-Q02 - Mid-Table Opportunities

-- Business Question:
-- Which mid-table teams performed above
-- their league averages?

-- Business Objective:
-- Identify competitive clubs outside the top four
-- for preliminary sponsorship screening.
;WITH MatchPoints AS (
SELECT
    m.league_id,
    m.season_id,
    m.home_team_id AS team_id,
    CASE
        WHEN m.home_team_goal > m.away_team_goal THEN 3
        WHEN m.home_team_goal = m.away_team_goal THEN 1
        ELSE 0
    END AS points
FROM dbo.[Match] m

UNION ALL

SELECT
    m.league_id,
    m.season_id,
    m.away_team_id AS team_id,
    CASE
        WHEN m.away_team_goal > m.home_team_goal THEN 3
        WHEN m.away_team_goal = m.home_team_goal THEN 1
        ELSE 0
    END AS points
FROM dbo.[Match] m
),
TeamSeasonStats AS (
    SELECT
        league_id,
        season_id,
        team_id,
        COUNT(*) AS matches_played,
        SUM(points) AS total_points,
        CAST(
            SUM(points) * 1.0 / COUNT(*)
            AS DECIMAL(5,2)
        ) AS points_per_match
    FROM MatchPoints
    GROUP BY
        league_id,
        season_id,
        team_id

),
RankedTeams AS (
    SELECT
        league_id,
        season_id,
        team_id,
        matches_played,
        total_points,
        points_per_match,
        RANK() OVER (
            PARTITION BY league_id, season_id
            ORDER BY total_points DESC
        ) AS league_rank
    FROM TeamSeasonStats
),

LeagueComparison AS (
    SELECT
        league_id,
        season_id,
        team_id,
        matches_played,
        total_points,
        points_per_match,
        league_rank,
        CAST(
            AVG(points_per_match) OVER (
                PARTITION BY league_id, season_id
            ) AS DECIMAL(5,2)
        ) AS league_avg_ppm
    FROM RankedTeams
)

-- JL-Q02 - Final Business Screening

SELECT
    l.league_name,
    s.season_name,
    t.team_long_name,
    lc.league_rank,
    lc.matches_played,
    lc.total_points,
    lc.points_per_match,
    lc.league_avg_ppm,
    CAST(
        lc.points_per_match - lc.league_avg_ppm
        AS DECIMAL(5,2)
    ) AS ppm_above_league_avg
FROM LeagueComparison lc
INNER JOIN dbo.Team t
    ON lc.team_id = t.team_id
INNER JOIN dbo.League l
    ON lc.league_id = l.league_id
INNER JOIN dbo.Season s
    ON lc.season_id = s.season_id
WHERE
    lc.points_per_match > lc.league_avg_ppm
    AND (
        (lc.league_id IN (1729, 21518)
            AND lc.league_rank BETWEEN 5 AND 10)
        OR
        (lc.league_id = 7809
            AND lc.league_rank BETWEEN 5 AND 9)
    )
ORDER BY
    l.league_name,
    s.season_name,
    lc.league_rank,
    t.team_long_name;


