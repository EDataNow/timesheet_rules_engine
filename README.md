# Table of Contents
- [Overview](#overview)
- [Installing](#installing)
- [Basic Usage](#basic-usage)
  - [Parameters](#parameters)
    - [Required](#required)
    - [Optional](#optional)
      - [Options](#options)
        - [Criteria Options](#criteria-options)
- [Output](#output)
- [Rules](#rules)
  - [Regional](#regional)
  - [Incentive](#incentive)
- [Excluding/Including Rules](#excluding/including-rules)

# Overview
`timesheet_rules_engine` is a rules engine that is used to process timesheets and spit out the Billable, Regular, Payable, Overtime, Downtime, Lunch and Total hours for a given set of timesheets.

# Installing
Add

```ruby
gem 'timesheet_rules_engine', git: 'https://github.com/EDataNow/timesheet_rules_engine', branch: 'master'
```

to your Gemfile and

```ruby
bundle install
```

# Basic Usage

```ruby
TimesheetRulesEngine.new(timesheets).process_timesheets
```

# Parameters

## Required
`timesheets`

A collection of timesheets that the hours will be calculated on.

## Optional

`options`

A hash that accepts the below [Options](#options)

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

`country` (String)

The country you are in.

**Default: 'ca'**

`region` (String)

The region of the country you are in.

**Default: 'on'**

`exclude_incentive_rules` (Boolean)

If you want to exclude all incentive rules from being used.

**Default: false**

`include_rules` (Array of Strings)

The list of [rules](#rules) that will be applied, empty means **all**.

**Default: []**

`exclude_rules` (Array of Strings)

The list of [rules](#rules) that will be excluded from being applied, empty means **none**.

**Default: []**

`no_rules` (Boolean)

If true, will apply no rules.

**Default: false**

`criteria` (Hash)

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

## Regional
- ### CA
  - ### ON
    - `IsHoliday`
    - `IsPartialOvertimeDay`
    - `MaximumDailyHours`
    - `MaximumWeeklyHours`
    - `MinimumDailyHours`
    - `MinimumWeeklyHours`
## Incentive
- `LeftEarlyButUnderMinimumWeekly`
- `QualifiesForDailyOvertimeAfterLeavingEarly`
- `QualifiesForMinimumAfterLeavingEarly`
- `QualifiesForWeeklyOvertimeAfterLeavingEarly`

# Excluding/Including Rules
If using exclude_rules or include_rules you will have to include the full path/class name for those rules. E.g 'Ca::On::IsHoliday', 'Incentive::LeftEarlyButUnderMinimumWeekly'.

If you want to exclude all incentive rules then use the option above.