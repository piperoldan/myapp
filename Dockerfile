FROM python:3.12-slim
WORKDIR /app

# Install system dependencies (SSH for Git)
RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/*

# Force wheel upgrade and install python requirements
RUN pip install --no-cache-dir --upgrade pip wheel==0.46.2
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 4000
CMD ["flask", "run", "--host=0.0.0.0", "--port=4000"]