drop table if exists ##s1_9d7bdae48be3445d92c372f566f1580d
;with
	s1 as (
		select
				cast('' as sysname) as db_name
				,cast('' as sysname) + ' ' + s.name + ' ' + o.name as n2
				,o.type_desc
			from sys.all_objects as o
				inner join sys.schemas as s on s.schema_id = o.schema_id
			where
				o.is_ms_shipped = 0
				and o.type_desc in (
					N'user_table',
					N'view')
	)
	select
		top (0)
			*
		into ##s1_9d7bdae48be3445d92c372f566f1580d
		from s1
	
declare @db_name_delimited nvarchar(max)
declare @db_name_as_string nvarchar(max)
declare @db_name_as_string_body nvarchar(max)
declare my_cursor cursor local forward_only fast_forward read_only for
	select
			quotename(name) as db_name_delimited
			,'''' + replace(name, '''', '''''') + '''' as db_name_as_string
			,replace(name, '''', '''''') as db_name_as_string_body
		from sys.databases
		order by 1
open my_cursor
while 1 = 1 begin
	fetch next from my_cursor into
		@db_name_delimited
		,@db_name_as_string
		,@db_name_as_string_body
	if @@fetch_status != 0 break
	declare @sql nvarchar(max) = '
		drop table if exists #t
		select
				' + @db_name_as_string + ' as db_name
				,' + @db_name_as_string + ' + '' '' + s.name + '' '' + o.name as n2
				,o.type_desc
			into #t
			from ' + @db_name_delimited + '.sys.all_objects as o
				inner join ' + @db_name_delimited + '.sys.schemas as s on s.schema_id = o.schema_id
			where
				o.is_ms_shipped = 0
				and o.type_desc in (
					N''user_table'',
					N''view'')
			order by 1, 2
		
		
		insert into ##s1_9d7bdae48be3445d92c372f566f1580d
			select
					*
				from #t
	'
	exec sp_executesql @sql;
end;
close my_cursor;
deallocate my_cursor;
select
		*
	from ##s1_9d7bdae48be3445d92c372f566f1580d
	for json auto
