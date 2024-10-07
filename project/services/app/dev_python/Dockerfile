FROM bitnami/python:3.12.6

RUN apt-get update && apt-get install -y netcat-openbsd

COPY conf/ ./
COPY tools/ /entrypoint/

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]

CMD ["python", "pong_project/manage.py", "runserver", "0.0.0.0:8000"]
