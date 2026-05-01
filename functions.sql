delimiter $$

-- Function to Get First Day of The Month Given any Date:
create function fn_month_start(p_date date)
returns date
deterministic
begin
	return last_day(p_date - interval 1 month) + interval 1 day;
end $$

delimiter ;