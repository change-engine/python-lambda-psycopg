# syntax=docker/dockerfile:1

FROM python:3.11-slim
WORKDIR /usr/src/app
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
    && PIP_DISABLE_PIP_VERSION_CHECK=true pip --no-cache-dir install awslambdaric
