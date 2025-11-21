	drop table if exists #pau__89a917d55fbd4e04ba4608c4d5e6ed05
	;with
		main as (
			select
					Partitions.object_id
					,Partitions.index_id
					,Partitions.partition_id
					,Partitions.partition_number
					,Partitions.rows
					,Partitions.data_compression_desc
					,AllocationUnits.type as allocation_unit_type
					,AllocationUnits.type_desc as allocation_unit_type_desc
					,AllocationUnits.total_pages
					,AllocationUnits.used_pages
						,iif((AllocationUnits.used_pages != 0), (1. * iif((AllocationUnits.type = 1), Partitions.rows, 0)) / (AllocationUnits.used_pages), 0) as inrows_per_page
				from sys.allocation_units as AllocationUnits
					inner join sys.partitions as Partitions on 
						case
							when AllocationUnits.type in (1,3) then Partitions.hobt_id
							else Partitions.partition_id
						end = AllocationUnits.container_id
		)
		select
				*
			into #pau__89a917d55fbd4e04ba4608c4d5e6ed05
			from main as main
	
	drop table if exists #tis
	;with
		s1 as (
			select
					Indexes.object_id
					,Indexes.index_id
					,min(cast(Indexes.is_unique as tinyint)) as IndexIsUnique
					,min(Indexes.name) as IndexName
					,min(Indexes.type_desc) as IndexTypeDesc
					,sum(PartitionsAllocationUnits.total_pages) as total_pages
					,sum(PartitionsAllocationUnits.used_pages) as used_pages
					,sum(iif((PartitionsAllocationUnits.allocation_unit_type = 1), PartitionsAllocationUnits.used_pages, 0)) as inrow_used_pages
					,sum(iif((PartitionsAllocationUnits.allocation_unit_type = 3), PartitionsAllocationUnits.used_pages, 0)) as rof_used_pages
					,sum(iif((PartitionsAllocationUnits.allocation_unit_type = 2), PartitionsAllocationUnits.used_pages, 0)) as lob_used_pages
					,sum(iif((PartitionsAllocationUnits.allocation_unit_type = 1), PartitionsAllocationUnits.rows, 0)) as rows
						,iif((sum(PartitionsAllocationUnits.used_pages) != 0), (1. * sum(iif((PartitionsAllocationUnits.allocation_unit_type = 1), PartitionsAllocationUnits.rows, 0))) / (sum(PartitionsAllocationUnits.used_pages)), 0) as avg_rows_per_page
				from #pau__89a917d55fbd4e04ba4608c4d5e6ed05 as PartitionsAllocationUnits
					inner join sys.indexes as Indexes on 
						Indexes.object_id = PartitionsAllocationUnits.object_id
						and Indexes.index_id = PartitionsAllocationUnits.index_id
				group by
					Indexes.object_id
					,Indexes.index_id
		)
		select
				*
				,sum(total_pages) over(partition by object_id order by object_id) as total_pages_per_object
				,sum(used_pages) over(partition by object_id order by object_id) as used_pages_per_object
			into #tis
			from s1
	
	select
			object_schema_name(Objects.object_id, db_id()) + '.' + object_name(Objects.object_id, db_id()) as n2
			,TablesIndexesSizes.*
		from #tis as TablesIndexesSizes
			inner join sys.all_objects as Objects on Objects.object_id = TablesIndexesSizes.object_id
		order by n2
