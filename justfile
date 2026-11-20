start-docker:
    docker-compose up -d

stop-docker:
    docker-compose down

stats-docker:
    docker-compose ps

build:
    @go build -o bin/api ./cmd/api
