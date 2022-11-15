# syntax=docker/dockerfile:1

FROM python:3.11 AS build
RUN PIP_DISABLE_PIP_VERSION_CHECK=true pip wheel multidict yarl frozenlist

FROM python:3.11-slim
WORKDIR /usr/src/app
COPY --from=build /root/.cache/pip/wheels/*/*/*/*/*.whl ./
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie-arm64 /usr/local/bin/aws-lambda-rie
COPY <<EOF /lambda-entrypoint.sh
#!/bin/sh
if [ -z "\${AWS_LAMBDA_RUNTIME_API}" ]; then
  exec /usr/local/bin/aws-lambda-rie /usr/local/bin/python -m awslambdaric \$@
else
  exec /usr/local/bin/python -m awslambdaric \$@
fi
EOF
ENTRYPOINT ["/lambda-entrypoint.sh"]
RUN chmod +x /usr/local/bin/aws-lambda-rie /lambda-entrypoint.sh \
    && apt-get update --quiet \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --quiet \
        libpq5 \
        libgeos-c1v5 \
    && rm -rf /var/lib/apt/lists/* \
    && PIP_DISABLE_PIP_VERSION_CHECK=true pip --no-cache-dir install *.whl
