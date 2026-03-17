drop table if exists ##s1_9d7bdae48be3445d92c372f566f1580d
;with
	s1 as (
		select
				cast('' as sysname) as db_name
				,n3 = cast(lower(cast('' as sysname)) as varchar(max)) + N' ' + cast(lower(referencing_s.name) as varchar(max)) + N' ' + cast(lower(referencing_o.name) as varchar(max))
				,dep.referenced_server_name as depends_on_server_name
				,depends_on_n3 = cast(lower(coalesce(dep.referenced_database_name, db_name())) as varchar(max)) + N' ' + cast(lower(dep.referenced_schema_name) as varchar(max)) + N' ' + cast(lower(dep.referenced_entity_name) as varchar(max))
			from sys.sql_expression_dependencies as dep
				left outer join sys.objects as referencing_o on referencing_o.object_id = dep.referencing_id
				left outer join sys.schemas as referencing_s on referencing_s.schema_id = referencing_o.schema_id
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
				,n3 = cast(lower(' + @db_name_as_string + ') as varchar(max)) + N''.'' + cast(lower(referencing_s.name) as varchar(max)) + N''.'' + cast(lower(referencing_o.name) as varchar(max))
				,dep.referenced_server_name as depends_on_server_name
				,depends_on_n3 = cast(lower(coalesce(dep.referenced_database_name, db_name())) as varchar(max)) + N''.'' + cast(lower(dep.referenced_schema_name) as varchar(max)) + N''.'' + cast(lower(dep.referenced_entity_name) as varchar(max))
			into #t
			from ' + @db_name_delimited + '.sys.sql_expression_dependencies as dep
				left outer join ' + @db_name_delimited + '.sys.objects as referencing_o on referencing_o.object_id = dep.referencing_id
				left outer join ' + @db_name_delimited + '.sys.schemas as referencing_s on referencing_s.schema_id = referencing_o.schema_id
			order by 1
		
		
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
