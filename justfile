# Pick another service with: just service=auth migrate-up
service := env_var_or_default("SERVICE", "wallet")
db_url := env_var_or_default("DB_URL", "postgres://payments:payments@localhost:5800/" + service + "?sslmode=disable")
migrate := "migrate -path db/" + service + "/migrations -database '" + db_url + "'"

default:
    @just --list

start-docker:
    @docker-compose up -d

stop-docker:
    @docker-compose down

stats-docker:
    @docker-compose ps

# Apply all pending migrations, or N of them: just migrate-up 1
migrate-up steps="":
    @{{ migrate }} up {{ steps }}

# Roll back N migrations (default 1): just migrate-down 2
migrate-down steps="1":
    @{{ migrate }} down {{ steps }}

# Show the current migration version
migrate-version:
    @output=$({{ migrate }} version 2>&1); status=$?; if [ "$status" -eq 0 ]; then printf '%s\n' "$output"; elif [ "$output" = "error: no migration" ]; then printf '%s\n' '0 migrations applied'; else printf '%s\n' "$output" >&2; exit "$status"; fi

# Create a new sequential migration: just migrate-new add_users_table
migrate-new name:
    @migrate create -ext sql -dir db/{{ service }}/migrations -seq {{ name }}

build:
    @go build -o bin/api ./cmd/api
