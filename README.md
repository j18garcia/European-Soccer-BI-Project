# Jose Luis — Business Analytics & SQL

## European Soccer BI | CAP2761C Intermediate Analytics

**Project focus:** Team Performance & Business Opportunities

**Database:** Azure SQL Database — `EuropeanSoccerBI`

**Scope:** England Premier League, Germany 1. Bundesliga, and Spain LIGA BBVA, covering five seasons (2011/2012–2015/2016).

## Business Objective

Analyze historical football performance to identify teams that may warrant further evaluation for sponsorship, advertising, and sports marketing opportunities.

The analysis uses sporting performance indicators only. Financial returns, sponsorship costs, audience reach, and commercial profitability are outside the available dataset.

## SQL Business Questions

| Query | Business Question | Initial Result |
|---|---|---|
| JL-Q01 | Which teams achieved the highest overall win rates? | 55 qualifying teams |
| JL-Q02 | Which mid-table teams performed above their league averages? | 48 team-season observations |
| JL-Q03 | Which teams maintained consistent performance across seasons? | 17 qualifying teams |
| JL-Q04 | Which teams improved their performance between the first and last seasons? | 44 qualifying teams |

## SQL Techniques

`SELECT`, `INNER JOIN`, `CASE WHEN`, `UNION ALL`, `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `CAST`, `DISTINCT`, `CTE`, `RANK()`, `OVER (PARTITION BY)`, `ORDER BY`.

## Initial Key Findings

- **JL-Q01:** FC Bayern Munich led with a 78.82% win rate.
- **JL-Q02:** Identified mid-table team-season performances above their respective league averages.
- **JL-Q03:** Tottenham Hotspur had the lowest PPM range (0.21) among qualifying teams.
- **JL-Q04:** Atlético Madrid showed the largest first-to-last-season PPM improvement (approximately +0.84).

## Supporting Files

- SQL scripts: `sql/jose_luis/`
- Query outputs (CSV and Excel): `results/jose_luis/`
- Execution screenshots: `evidence/jose_luis/`
- Visualizations: Pending

## Validation and Limitations

All four SQL queries were successfully executed against Azure SQL Database. Results are preliminary analytical outputs, subject to final methodology and presentation review.

Mid-table positioning is based on a points-only ranking; official league tie-breaking rules are not applied. Analysis uses historical sporting data and should not be interpreted as a financial investment recommendation.

**Contributor:** Jose Luis Garcia
