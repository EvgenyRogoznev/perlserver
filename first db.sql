sudo -u postgres psql
CREATE ROLE chat_user WITH LOGIN PASSWORD '03bepuh';
create database firstdb with owner ro;
psql -Uchat_user -h127.0.0.1 -dchat_history;
CREATE TABLE msg_history(id serial PRIMARY KEY, chat_user_name  text, msg text);


