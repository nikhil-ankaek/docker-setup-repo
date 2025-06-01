DB_HOST        ?= postgres
DB_PORT        ?= 5432
DB_USER        ?= postgres
DB_PASSWORD    ?= postgres

MIGRATIONS_BASE ?= projects
MIGRATIONS_DIR  ?= internal/adapter/storage/postgres/migrations

# Example: make migration name=create_users service=auth-service
migration:
	@if [ -z "$(name)" ] || [ -z "$(service)" ]; then \
		echo "❌ Usage: make migration name=your_migration_name service=your-service"; \
		exit 1; \
	fi; \
	docker exec -i migrate mkdir -p /migrations/$(service); \
	docker cp $(MIGRATIONS_BASE)/$(service)/$(MIGRATIONS_DIR) migrate:/migrations/$(service); \
	docker exec -i migrate migrate create -ext sql -dir /migrations/$(service) $(name); \
	docker cp migrate:/migrations/$(service) $(MIGRATIONS_BASE)/$(service)/$(MIGRATIONS_DIR); \
	echo "✅ Created migration $(name) for $(service)"

# Example: make migrate-up service=auth-service DB_NAME=auth_db
migrate-up:
	@if [ -z "$(service)" ] || [ -z "$(DB_NAME)" ]; then \
		echo "❌ Usage: make migrate-up service=your-service DB_NAME=your_db"; \
		exit 1; \
	fi; \
	docker cp $(MIGRATIONS_BASE)/$(service)/$(MIGRATIONS_DIR) migrate:/migrations/$(service); \
	docker exec -i migrate migrate -path /migrations/$(service) \
	  -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" up

# Example: make migrate-down service=auth-service DB_NAME=auth_db
migrate-down:
	@if [ -z "$(service)" ] || [ -z "$(DB_NAME)" ]; then \
		echo "❌ Usage: make migrate-down service=your-service DB_NAME=your_db"; \
		exit 1; \
	fi; \
	docker cp $(MIGRATIONS_BASE)/$(service)/$(MIGRATIONS_DIR) migrate:/migrations/$(service); \
	docker exec -i migrate migrate -path /migrations/$(service) \
	  -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" down
