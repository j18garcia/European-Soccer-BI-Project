-- CAP2761C - European Soccer BI
-- Author: Jose Luis Garcia
-- Query: JL-Q01 - Historical Team Win Rate

-- Business Question:
-- Which teams achieved the highest overall win rates
-- across the five seasons in the selected leagues?

-- Business Objective:
-- Identify historically high-performing teams as a first
-- screening indicator for potential sponsorship opportunities.

;WITH TeamMatches AS (
    -- Home matches perspective
    SELECT
        l.league_name,
        t.team_id,
        t.team_long_name,
        s.season_name,
        1 AS matches_played,
        CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END AS win_flag,
        CASE WHEN m.home_team_goal = m.away_team_goal THEN 1 ELSE 0 END AS draw_flag,
        CASE WHEN m.home_team_goal < m.away_team_goal THEN 1 ELSE 0 END AS loss_flag
    FROM dbo.[Match] m
    INNER JOIN dbo.Team t
        ON m.home_team_id = t.team_id
    INNER JOIN dbo.League l
        ON m.league_id = l.league_id
    INNER JOIN dbo.Season s
        ON m.season_id = s.season_id

    UNION ALL

    -- Away matches perspective
    SELECT
        l.league_name,
        t.team_id,
        t.team_long_name,
        s.season_name,
        1 AS matches_played,
        CASE WHEN m.away_team_goal > m.home_team_goal THEN 1 ELSE 0 END AS win_flag,
        CASE WHEN m.away_team_goal = m.home_team_goal THEN 1 ELSE 0 END AS draw_flag,
        CASE WHEN m.away_team_goal < m.home_team_goal THEN 1 ELSE 0 END AS loss_flag
    FROM dbo.[Match] m
    INNER JOIN dbo.Team t
        ON m.away_team_id = t.team_id
    INNER JOIN dbo.League l
        ON m.league_id = l.league_id
    INNER JOIN dbo.Season s
        ON m.season_id = s.season_id
)

SELECT
    league_name,
    team_long_name,
    COUNT(*) AS total_matches,
    SUM(win_flag) AS total_wins,
    SUM(draw_flag) AS total_draws,
    SUM(loss_flag) AS total_losses,
    CAST(SUM(win_flag) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS win_rate_pct
FROM TeamMatches
GROUP BY
    league_name,
    team_long_name
HAVING COUNT(DISTINCT season_name) >= 3
ORDER BY
    win_rate_pct DESC,
    total_wins DESC,
    team_long_name ASC;