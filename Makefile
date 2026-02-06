default: info

info:
	@echo "Available targets:"
	@echo "   make setup-db:     to spin up a Spanner emulator instance and create a database"
	@echo "   make setup-table:  to create and populate a table with a fuzzy search index"
	@echo "   make drop-table:   to drop the index and table"
	@echo ""
	@echo "Once the table has been created and populated, you can run search queries with:"
	@echo "   ./run-sql-script.sh ./sql-scripts/search-query.sql 'search key'"
	@echo ""



setup-db:
	./activate-gcloud-emulator-config.sh
	./launch-spanner-emulator.sh
	@echo ""
	@echo "WARNING: gcloud is now configured to interact with the local database instance. To switch to the default configuration:"
	@echo "    gcloud config configurations activate default"

setup-table:
	./run-sql-script.sh ./sql-scripts/create-table.sql
	./run-sql-script.sh ./sql-scripts/create-index.sql
	./run-sql-script.sh ./sql-scripts/populate-table.sql
	@echo "Now you can run search queries with ./run-sql-script.sh ./sql-scripts/search-query.sql"

drop-table:
	./run-sql-script.sh ./sql-scripts/drop-index.sql
	./run-sql-script.sh ./sql-scripts/drop-table.sql
	


