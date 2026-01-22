FROM python:3.12-slim
WORKDIR /app

# Install everything in one go, forcing the wheel upgrade first
RUN pip install --no-cache-dir --upgrade pip wheel==0.46.2
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 4000
CMD ["flask", "run", "--host=0.0.0.0", "--port=4000"]