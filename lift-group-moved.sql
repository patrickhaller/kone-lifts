-- how many ppl moved during load window
create schema if not exists ph;
create or replace function ph.lift_group_moved (lift_group varchar, window_start timestamp, window_end timestamp)
returns table (lift_group text, people double precision) as $$
select c_group_name_fk, 
    sum( abs(start_floor_index - end_floor_index) -- floors travel'd
        * floor(start_load / 3) -- ppl, where 60% is full load of 20 ppl
    ) / 8 -- floors 6, 7, 8 , 9, 10 go to floor 1, so mean is 8
from ods.elevator_cycle_r
where true
and source_row_created > window_start
and source_row_created < window_end
and c_group_name_fk = lift_group
group by c_group_name_fk
;
$$ language sql;
