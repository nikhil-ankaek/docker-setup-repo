DB_HOST        ?= postgres
DB_PORT        ?= 5432
DB_USER        ?= postgres
DB_PASSWORD    ?= postgres
MIGRATIONS_DIR ?= internal/adapter/storage/postgres/migrations

migration:
	@if [ -z "$(name)" ]; then \
		echo "❌ Usage: make migration name=your_migration_name service=your-service-name"; \
		exit 1; \
	fi; \
	if [ -z "$(service)" ]; then \
		echo "❌ Please specify the service container. Example: service=auth-service"; \
		exit 1; \
	fi; \
	docker exec -it $(service) migrate create -ext sql -dir /app/$(MIGRATIONS_DIR) $(name); \
	echo "✅ Created migration $(name) in $(service)/$(MIGRATIONS_DIR)"

migrate-up:
	@if [ -z "$(service)" ] || [ -z "$(DB_NAME)" ]; then \
		echo "❌ Usage: make migrate-up service=your-service DB_NAME=aok_connect_db"; \
		exit 1; \
	fi; \
	docker exec -it $(service) migrate -path /app/$(MIGRATIONS_DIR) \
	  -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" up; \
	echo "✅ Applied UP migrations for $(service) → $(DB_NAME)"

migrate-down:
	@if [ -z "$(service)" ] || [ -z "$(DB_NAME)" ]; then \
		echo "❌ Usage: make migrate-down service=your-service DB_NAME=aok_connect_db"; \
		exit 1; \
	fi; \
	docker exec -it $(service) migrate -path /app/$(MIGRATIONS_DIR) \
	  -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" down; \
	echo "⏬ Rolled back DOWN migrations for $(service) → $(DB_NAME)"