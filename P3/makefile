run:
	docker exec -it lab-bd-app streamlit run src/main.py

run-bash:
	streamlit run src/main.py

bash:
	docker exec -it lab-bd-app bash

down:
	docker compose down -v

build:
	docker build -t lab-bd-app .

up: build
	docker compose up -d
