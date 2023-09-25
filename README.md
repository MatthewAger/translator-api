```bash
bundle install
bin/rails db:create db:migrate
bundle exec rspec spec -fd
```

To test the endpoints
```bash
bin/rails db:seed
```
and see output for example `curl` command including JWT for generated user.

To use docker
```bash
docker compose up develpoment
docker compose up test
```
