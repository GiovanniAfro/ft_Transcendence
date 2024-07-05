FROM python:3.12.4-bookworm

WORKDIR /usr/src/app

COPY conf/requirements.txt ./
COPY conf/ft_transcendence ./ft_transcendence

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

# CMD ["python", "ft_transcendence/manage.py", "collectstatic", "--noinput"]
CMD ["python", "ft_transcendence/manage.py", "migrate"]
CMD ["python", "ft_transcendence/manage.py", "runserver", "10.0.0.1:8000"]
