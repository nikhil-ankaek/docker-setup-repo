DB_HOST        ?= postgres
DB_PORT        ?= 5432
DB_USER        ?= postgres
DB_PASSWORD    ?= postgres
MIGRATIONS_BASE ?= /projects
MIGRATIONS_DIR ?= /internal/adapter/storage/postgres

migration:
	@if [ -z "$(name)" ] || [ -z "$(service)" ]; then \
		echo "❌ Usage: make migration name=your_migration_name service=your-service-name"; \
		exit 1; \
	fi; \
	docker exec -it migrate migrate create -ext sql -dir $(MIGRATIONS_BASE)/$(service)$(MIGRATIONS_DIR)/migrations $(name); \
	echo "✅ Created migration $(name) in $(service)"

migrate-up:
	@if [ -z "$(service)" ] || [ -z "$(DB_NAME)" ]; then \
		echo "❌ Usage: make migrate-up service=your-service DB_NAME=yourdb"; \
		exit 1; \
	fi; \
	docker exec -it migrate migrate -path $(MIGRATIONS_BASE)/$(service)$(MIGRATIONS_DIR)/migrations \
	-database "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" up; \
	echo "✅ Applied UP migrations for $(service) → $(DB_NAME)"

migrate-down:
	@if [ -z "$(service)" ] || [ -z "$(DB_NAME)" ]; then \
		echo "❌ Usage: make migrate-down service=your-service DB_NAME=yourdb"; \
		exit 1; \
	fi; \
	docker exec -it migrate migrate -path $(MIGRATIONS_BASE)/$(service)$(MIGRATIONS_DIR)/migrations \
	-database "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" down; \
	echo "⏬ Rolled back migrations for $(service) → $(DB_NAME)"