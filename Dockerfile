# Stage 1: The Builder (the heavy lifter)
FROM python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
# Install dependencies into a specific folder
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: The Final Image (the tiny one)
FROM python:3.9-slim
WORKDIR /app

# Only copy the installed libraries from the builder stage
COPY --from=builder /root/.local /root/.local
COPY . .

# Update PATH so Python can find the libraries
ENV PATH=/root/.local/bin:$PATH

EXPOSE 4000
CMD ["flask", "run", "--host=0.0.0.0", "--port=4000"]