FROM postgres:12.1
RUN apt update && apt -y upgrade && apt install -y sudo
COPY srcs/init.sql /docker-entrypoint-initdb.d/
COPY srcs/postgresql/pong_development_db /
COPY srcs/postgresql/pong_test_db /
COPY srcs/postgresql/pong_production_db /
# ENTRYPOINT sudo -i -u postgres; psql pong_development < /pong_development_db; psql pong_test < /pong_test_db; psql pong_production < /pong_production_db; sudo service postgresql restart;