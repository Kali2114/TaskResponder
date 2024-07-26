FROM python:3.12.3-alpine3.19
LABEL maintainer="snapscene.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app
COPY ./scripts /scripts
WORKDIR /app
EXPOSE 8000

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    chown -R django-user /app /scripts && \
    chmod +x /scripts/run.sh


ENV PATH="/py/bin:$PATH"
USER django-user
CMD ["sh", "/scripts/run.sh"]