FROM python:3.6-jessie

RUN apt update

WORKDIR /app

ADD requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

ADD ./*.py /app

ENV PORT 80
CMD ["gunicorn", "app:app", "--config=config.py"]
