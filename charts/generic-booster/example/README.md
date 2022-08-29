## Spring Boot
```
helm upgrade --install xxx generic-booster/ -f generic-booster/example/spring-boot-values.yaml
```

## hpa
## hpa-test
```
helm diff upgrade --install hpa-test hellokku/generic-booster -f hpa-test-values.yaml
```

## mysql
```
helm upgrade --install mysql hellokku/generic-booster -f mysql-values.yaml
```

## nginx
```
helm upgrade --install nginx hellokku/generic-booster -f nginx-values.yaml
```