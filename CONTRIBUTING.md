# Contributing

Issues and pull requests are welcome: https://github.com/mihailpolakov/php-nginx/issues

When reporting a bug, include:
- the image tag you use
- your `Dockerfile` (if you extend the image) and the command used to run the container
- what you expected and what actually happened

Before opening a pull request, make sure the image builds and the smoke test passes:

```bash
docker build -t php-nginx:test .
./run_tests.sh php-nginx:test
```

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
