FROM python:3.10-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python -

# Install Poetry export plugin
RUN /root/.local/bin/poetry self add poetry-plugin-export

# Install dependencies
COPY poetry.lock pyproject.toml ./
RUN /root/.local/bin/poetry export -o requirements.txt
RUN pip install -r requirements.txt --no-cache-dir

# Install module
COPY . .
RUN python -m pip install -e . --no-cache-dir --no-deps

# Generate crontab task
RUN echo '#!/bin/sh' > /docker-entrypoint.sh
RUN echo 'echo "${CRON_SCHEDULE} /usr/local/bin/python /src/main.py --url \"${KUMA_PUSH_URL}\" > /proc/1/fd/1 2>&1 \n" > crontab' >> /docker-entrypoint.sh
RUN echo 'crontab crontab' >> /docker-entrypoint.sh
RUN echo 'cron &' >> /docker-entrypoint.sh
RUN echo 'tail -f /dev/null' >> /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
