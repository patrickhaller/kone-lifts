-- how many ppl moved during load window

-- the following is really: create schema if not exists ph;
-- BEGIN dinosaur createifnx
create or replace function _ph_do_func() returns void as
$$
begin
	if not exists(
		select schema_name
		from information_schema.schemata
		where schema_name = 'ph'
	)
	then
		execute 'create schema pg';
	end if;
end
$$ language plpgsql volatile;
select _ph_do_func();
drop function _ph_do_func();
-- END dinosaur createifnx

create or replace function ph.lift_group_moved (varchar, timestamp, timestamp)
-- (lift_group varchar, window_start timestamp, window_end timestamp)
returns table (lift_group text, people double precision) as $$
select c_group_name_fk, 
    sum( abs(start_floor_index - end_floor_index) -- floors travel'd
        * floor(start_load / 3) -- ppl, where 60% is full load of 20 ppl
    ) / 8 -- floors 6, 7, 8 , 9, 10 go to floor 1, so mean is 8
from ods.elevator_cycle_r
where true
and c_group_name_fk = $1
and source_row_created > $2 
and source_row_created < $3
group by c_group_name_fk
;
$$ language sql;
