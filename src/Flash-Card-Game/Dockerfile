# syntax=docker/dockerfile:1

FROM node:22-alpine

LABEL maintainer="DE:AD:10:C5 <thedevilsvoice@dead10c5.org>"
LABEL org.opencontainers.image.source = "https://github.com/devsecfranklin/lab-franklin"
LABEL org.opencontainers.image.description="lab-franklin"
LABEL org.opencontainers.image.licenses=GPLv2

ENV NODE_ENV=production

COPY . .

# Set up postgresql
RUN npm install -g nodemon; \
  apk update && apk add postgresql postgresql-jit; \
  mkdir /run/postgresql;\
  chown -R postgres:postgres /run/postgresql/; \
  mkdir /var/lib/postgresql/data;\
  chown -R postgres:postgres /var/lib/postgresql/; \
  chmod 777 /var/lib/postgresql/data; \
  su - postgres -c "initdb /var/lib/postgresql/data"

# Run the database in the backend
RUN echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf; \
  echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf; \
  su - postgres -c "pg_ctl start -D /var/lib/postgresql/data"; \
  echo "TEST:" && find /run/postgresql/ -name .s.PGSQL.5432; \
  echo "TEST:" && pwd;\
  cp .env.dev .env; \
  cd server && npm install; \
  su - postgres -c "npm run seed:db"; \
  npm start

#EXPOSE 5432
#ENTRYPOINT ["node", "server.js"]

RUN nodemon server/server.js localhost