create-emulator:
	./activate-gcloud-emulator-config.sh
	./launch-spanner-emulator.sh

populate-table:
	./run-sql-script.sh ./sql-scripts/create-table.sql
	./run-sql-script.sh ./sql-scripts/create-index.sql
	./run-sql-script.sh ./sql-scripts/populate-table.sql
	echo "Now you can run search queries with ./run-sql-script.sh ./sql-scripts/search-query.sql"

drop-table:
	./run-sql-script.sh ./sql-scripts/drop-index.sql
	./run-sql-script.sh ./sql-scripts/drop-table.sql
	


