FROM python:3.12-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY python/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY python/demo.py /app/demo.py
USER 10001:10001
CMD ["python", "demo.py"]
