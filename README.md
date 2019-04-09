# Table of Contents
- [Overview](#overview)
- [Installing](#installing)
- [Basic Usage](#basic-usage)
  - [Params](#params)
  - [Options](#options)
    - [Criteria Options](#criteria-options)
- [Output](#output)
- [Rules](#rules)

# Overview
`timesheet_rules_engine` is a rules engine that is used to process timesheets and spit out the Billable, Regular, Payable, Overtime, Downtime, Lunch and Total hours for a given set of timesheets.

# Installing
Add
`gem 'timesheet_rules_engine', git: 'https://github.com/EDataNow/timesheet_rules_engine', branch: 'master'`

to your Gemfile and

`bundle install`

# Basic Usage

```ruby
TimesheetRulesEngine.new(timesheets).process_timesheets
```

## Params

`timesheets`

This is a collection of timesheets that the hours will be calculated on.

`options`

The options hash is an optional second params that accepts the below [Options](#options)

eg.

```ruby
{
  criteria: nil,
  include_rules: [],
  exclude_rules: [],
  no_rules: false
}
```

## Options

`criteria`

This is a hash that includes the following information on default but can be modified by passing in your own via options hash

### Criteria Options

**Default:**
```ruby
{
  minimum_daily_hours: 3.0,
  maximum_daily_hours: 8.0,
  minimum_weekly_hours: 44.0,
  maximum_weekly_hours: 60.0,
  overtime_days: ["saturday", "sunday"],
  saturdays_overtime: true,
  sundays_overtime: true,
  holidays_overtime: true,
  decimal_place: 2,
  billable_hour: 0.25,
  closest_minute: 8.0,
  scheduled_shift: nil
}

```

`include_rules`

The list of [rules](#rules) that will be applied, empty means **all**.

**Default: []**

`exclude_rules`

The list of [rules](#rules) that will be excluded from being applied, empty means **none**.

**Default: []**

`no_rules`

If true, will apply no rules.

**Default: false**

# Output

This will result in a hash that has a structure like

```ruby
  {
    billable: 0.0,
    downtime: 0.0,
    lunch: 0.0,
    regular: 0.0,
    minimum_regular: 0.0,
    payable: 0.0,
    overtime: 0.0,
    total: 0.0
  }
```

# Rules

- `IsBilled`
- `IsDowntime`
- `IsLunch`
- `IsOutsideRegularSchedule`
- `IsOvertimeActivityType`
- `IsOvertimeDay`
- `IsOvertimePaid`
- `IsPaid`
- `IsPartialOvertimeDay`
- `MaximumDailyHours`
- `MaximumWeeklyHours`
- `MinimumDailyHours`
- `MinimumWeeklyHours`